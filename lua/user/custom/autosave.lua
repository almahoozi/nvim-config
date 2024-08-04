-- TODO: Make into a plugin
-- TODO: Clean up
-- TODO: Support more granularity; only run tests for the current file, just current test, package, etc
-- TODO: Support other languages, or at least structure it so that other languages can be supported

local test_function_query_string = [[
(
 (function_declaration
  name: (identifier) @name
  parameters:
    (parameter_list
     (parameter_declaration
      name: (identifier)
      type: (pointer_type
          (qualified_type
           package: (package_identifier) @_package_name
           name: (type_identifier) @_type_name)))))

 (#eq? @_package_name "testing")
 (#eq? @_type_name "T")
 (#eq? @name "%s")
)
]]

local find_test_line = function(go_bufnr, name)
	local formatted = string.format(test_function_query_string, name)
	local query = vim.treesitter.query.parse("go", formatted)
	local parser = vim.treesitter.get_parser(go_bufnr, "go", {})
	local tree = parser:parse()[1]
	local root = tree:root()

	for id, node in query:iter_captures(root, go_bufnr, 0, -1) do
		if id == 1 then
			local range = { node:range() }
			return range[1]
		end
	end
end

local make_key = function(entry)
	assert(entry.Package, "Must have Package:" .. vim.inspect(entry))
	assert(entry.Test, "Must have Test:" .. vim.inspect(entry))
	return string.format("%s/%s", entry.Package, entry.Test)
end

local add_golang_test = function(state, entry)
	state.tests[make_key(entry)] = {
		name = entry.Test,
		line = find_test_line(state.bufnr, entry.Test),
		output = {},
	}
end

local add_golang_output = function(state, entry)
	assert(state.tests, vim.inspect(state))
	table.insert(state.tests[make_key(entry)].output, vim.trim(entry.Output))
end

local mark_success = function(state, entry)
	state.tests[make_key(entry)].success = entry.Action == "pass"
end

local mark_skipped = function(state, entry)
	state.tests[make_key(entry)].skipped = true
end

-- local display_golang_output = function(state, bufnr) end

local ns = vim.api.nvim_create_namespace("live-tests")
local group = vim.api.nvim_create_augroup("auto-save-run-tests", { clear = true })

TestsInProgress = false

local attach_to_buffer = function(bufnr, command)
	local state = {
		bufnr = bufnr,
		tests = {},
	}

	vim.api.nvim_buf_create_user_command(bufnr, "LiveTestDiag", function()
		local line = vim.fn.line(".") - 1
		for _, test in pairs(state.tests) do
			if test.line == line then
				vim.cmd.new()
				vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, test.output)
			end
		end
	end, {})

	local run_tests = function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		if TestsInProgress then
			return
		end

		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

		if not LiveTestsEnabled then
			return
		end

		state = {
			bufnr = bufnr,
			tests = {},
		}

		local on_output = function(_, data)
			if not data then
				return
			end

			for _, line in ipairs(data) do
				if not line or line == "" then
					goto continue
				end

				local ok, decoded = pcall(vim.json.decode, line)
				if not ok then
					print("LiveTests: Failed to decode line: " .. line)
					goto continue
				end

				if decoded.Action == "run" or decoded.Action == "start" then
					if not decoded.Test then
						goto continue
					end
					add_golang_test(state, decoded)
				elseif decoded.Action == "output" then
					if not decoded.Test then
						goto continue
					end

					add_golang_output(state, decoded)
				elseif decoded.Action == "pass" or decoded.Action == "fail" then
					if not decoded.Test then
						-- This is a package level test update
						goto continue
					end
					mark_success(state, decoded)

					local test = state.tests[make_key(decoded)]
					if test.success and test.line then
						local text = { "\t✓ Test Passed", "TestPassed" }
						-- Add the text to extmark as green virtual text
						vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, {
							virt_text = { text },
							hl_group = "TestPassed",
							--hl_mode = "combine",
							sign_text = "✓",
							sign_hl_group = "TestPassed",
						})
					end
				elseif decoded.Action == "pause" or decoded.Action == "cont" then
				-- Do nothing
				elseif decoded.Action == "skip" then
					-- Mark test as skipped, nothing to do if package level skip
					if decoded.Test then
						mark_skipped(state, decoded)
					end
				else
					error("Failed to handle" .. vim.inspect(data))
				end

				-- Continue the loop
				::continue::
			end
		end

		TestsInProgress = true
		vim.fn.jobstart(command, {
			stdout_buffered = true,
			on_stdout = on_output,
			on_stderr = on_output,
			on_exit = function()
				TestsInProgress = false
				local failed = {}
				for _, test in pairs(state.tests) do
					if test.line then
						if test.skipped then
							local output = ""
							for _, line in ipairs(test.output) do
								output = output .. line .. "\n"
							end
							table.insert(failed, {
								bufnr = bufnr,
								lnum = test.line,
								col = 0,
								severity = vim.diagnostic.severity.INFO,
								source = "live-test",
								message = output,
								user_data = {
									virtual_text = "⚠ Test Skipped",
								},
							})
						elseif not test.success then
							local output = ""
							for _, line in ipairs(test.output) do
								output = output .. line .. "\n"
							end
							table.insert(failed, {
								bufnr = bufnr,
								lnum = test.line,
								col = 0,
								severity = vim.diagnostic.severity.ERROR,
								source = "live-test",
								message = output,
								user_data = {
									virtual_text = "✗ Test Failed",
								},
							})
						end
					end
				end

				vim.diagnostic.set(ns, bufnr, failed, {
					virtual_text = {
						prefix = "",
						format = function(diagnostic)
							if diagnostic.user_data.virtual_text then
								return diagnostic.user_data.virtual_text
							end
							return diagnostic.message
						end,
					},
				})
			end,
		})
	end

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.go",
		callback = run_tests,
	})

	run_tests()
end

-- Whether the flag should be enabled by default should be persisted
-- in the user's config
-- Check whether the current root exists in the config
-- If it does, then enable or disable the tests based on the config
-- ... The config is a json in the format { "{root_dir}": true/false}"}
LiveTestsEnabled = false
local get_root = function()
	local cwd = vim.fn.getcwd()
	local gomod = vim.fn.findfile("go.mod", cwd .. ";")
	if gomod == "" then
		return
	end
	return vim.fn.fnamemodify(gomod, ":p:h")
end

local config_file = vim.fn.stdpath("config") .. "/.config/live-tests.json"
-- Execute the following code after the thing has been loaded
vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	pattern = "*",
	callback = function()
		local root = get_root()
		if root ~= nil then
			local config = {}
			if vim.fn.filereadable(config_file) == 1 then
				config = vim.fn.json_decode(vim.fn.readfile(config_file))
			end

			if config[root] ~= nil then
				LiveTestsEnabled = config[root]
				if LiveTestsEnabled then
					vim.cmd("echo 'Live Tests Enabled'")
				end
			end
		end
	end,
})

vim.api.nvim_create_user_command("LiveTestStatus", function()
	if LiveTestsEnabled then
		vim.cmd("echo 'Live Tests Enabled'")
	else
		vim.cmd("echo 'Live Tests Disabled'")
	end
end, {})

vim.api.nvim_create_user_command("LiveTestToggle", function()
	LiveTestsEnabled = not LiveTestsEnabled
	-- Update the config
	local config = {}
	if vim.fn.filereadable(config_file) == 1 then
		config = vim.fn.json_decode(vim.fn.readfile(config_file))
	end

	local root = get_root()
	if root ~= nil then
		config[root] = LiveTestsEnabled
	end

	vim.fn.writefile({ vim.fn.json_encode(config) }, config_file)

	if LiveTestsEnabled then
		vim.cmd("echo 'Live Tests Enabled'")
	else
		vim.cmd("echo 'Live Tests Disabled'")
	end
end, {})

-- Only when buffer first opens
vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	pattern = "*_test.go",
	callback = function()
		attach_to_buffer(vim.api.nvim_get_current_buf(), { "go", "test", "./...", "-tags=tests", "-v", "-json" })
	end,
})
