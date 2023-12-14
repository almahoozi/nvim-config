-- Sets up dap event listners and keymaps; listeners also set up dap specific
-- keymaps which are set during a debug session and removed after

require("dap-go").setup()

local dap = require("dap")
local widgets = require("dap.ui.widgets")
local dapui = require("dapui")
dapui.setup()

local dap_keymaps = {
	{ { "n" }, "<C-CR>", dap.continue },
	{ { "n" }, "<C-j>", dap.step_over },
	{ { "n" }, "<C-l>", dap.step_into },
	{ { "n" }, "<C-h>", dap.step_out },
	{ { "n" }, "<c-up>", dap.up },
	{ { "n" }, "<c-down>", dap.down },
	{
		{ "n" },
		"<C-esc>",
		function()
			dapui.close()
			dap.terminate()
			dap.close()
		end,
	},
	{ { "n" }, "<leader> ", dap.run_to_cursor },
	{ { "n" }, "<C-z>", dap.focus_frame },
	-- The LSP "K" keymap takes over in 'n' mode (since it's applied on buf)
	{ { "n", "v" }, "K", widgets.hover },
	{ { "n", "v" }, "<C-k>", widgets.hover },
}
local old_keymaps = {}
local opts = { noremap = true, silent = true }

-- Normalize lhs; leader is replaced and <c- <a- <s- <cr> <tab> <space> <down> .. etc are uppercased
local function normalize_lhs(lhs)
	lhs = lhs:gsub("<leader>", vim.g.mapleader)
	lhs = lhs:gsub("<[^->]+>", function(match)
		return match:upper()
	end)
	lhs = lhs:gsub("<([^->]+)-([^->])+>", function(ctrl_key_match, key_match)
		return "<" .. ctrl_key_match:upper() .. "-" .. key_match .. ">"
	end)
	return lhs
end

local function backup_keymaps()
	if #old_keymaps ~= 0 then
		return
	end

	local all_keymaps = {}
	for _, mode in ipairs({ "n", "v" }) do
		all_keymaps[mode] = vim.api.nvim_get_keymap(mode)
	end

	local index = {}
	for _, keymap in ipairs(dap_keymaps) do
		local modes = {}
		if type(keymap[1]) == "table" then
			modes = keymap[1]
		else
			modes = { keymap[1] }
		end

		for _, mode in ipairs(modes) do
			local lhs = normalize_lhs(keymap[2])
			index[mode .. lhs] = true
		end
	end

	for mode, keymaps in pairs(all_keymaps) do
		for _, keymap in ipairs(keymaps) do
			local lhs = normalize_lhs(keymap.lhs)
			if index[mode .. lhs] then
				table.insert(old_keymaps, keymap)
			end
		end
	end

	print("old_keymaps", vim.inspect(old_keymaps))
end

local function restore_keymaps()
	if #old_keymaps == 0 then
		return
	end

	for _, keymap in ipairs(dap_keymaps) do
		local modes = {}
		if type(keymap[1]) == "table" then
			modes = keymap[1]
		else
			modes = { keymap[1] }
		end

		for _, mode in ipairs(modes) do
			local lhs = normalize_lhs(keymap[2])
			pcall(function()
				vim.keymap.del(mode, lhs)
			end)
		end
	end

	for _, keymap in ipairs(old_keymaps) do
		vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
	end
	old_keymaps = {}
end

dap.listeners.after.event_initialized["dapui_config"] = function(session, body)
	print("Session initialized", vim.inspect(session), vim.inspect(body))
	backup_keymaps()
	for _, keymap in ipairs(dap_keymaps) do
		local modes = {}
		if type(keymap[1]) == "table" then
			modes = keymap[1]
		else
			modes = { keymap[1] }
		end

		for _, mode in ipairs(modes) do
			local lhs = normalize_lhs(keymap[2])
			pcall(function()
				vim.keymap.del(mode, lhs)
			end)
			vim.keymap.set(mode, lhs, keymap[3], opts)
		end
	end
	dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function(session, body)
	print("Session terminated", vim.inspect(session), vim.inspect(body))
	dapui.close()
	restore_keymaps()
end
dap.listeners.before.event_exited["dapui_config]"] = function(session, body)
	print("Session terminated", vim.inspect(session), vim.inspect(body))
	dapui.close()
	restore_keymaps()
end

-- Will keep those for the "traditional" keymaps
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>", opts)
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>", opts)
vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>", opts)
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>", opts)
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", opts)
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts)
vim.keymap.set("n", "<leader>dt", ":lua require('dap-go').debug_test()<CR>", opts)
vim.keymap.set("n", "<leader>dlt", ":lua require('dap-go').debug_last_test()<CR>", opts)
