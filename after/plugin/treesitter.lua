---@diagnostic disable: missing-fields
local ts_install = require("nvim-treesitter.install")

if vim.fn.executable("tree-sitter") == 1 then
	local help = table.concat(vim.fn.systemlist({ "tree-sitter", "generate", "--help" }), "\n")
	if not help:find("--no-bindings", 1, true) then
		local abi = vim.treesitter and vim.treesitter.language_version
		ts_install.ts_generate_args = abi and { "generate", "--abi", tostring(abi) } or { "generate" }
	end
end

require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = {
		"vimdoc",
		"javascript",
		"typescript",
		"go",
		"gotmpl",
		"gomod",
		--"swift",
		"kotlin",
		"c",
		"c_sharp",
		"bash",
		"cmake",
		"css",
		-- "dart",
		"dockerfile",
		"html",
		-- "htmx",
		"http",
		-- "java",
		"json",
		"latex",
		"markdown",
		"sql",
		"templ",
		"toml",
		"yaml",
		"tsx",
		"terraform",
		"regex",
		"proto",
		"php",
		"python",
		"lua",
		"rust",
		"zig",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	highlight = {
		-- `false` will disable the whole extension
		enable = true,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
		max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
	},
})

if vim.fn.has("nvim-0.12") == 1 then
	local query = require("vim.treesitter.query")

	local html_script_type_languages = {
		["importmap"] = "json",
		["module"] = "javascript",
		["application/ecmascript"] = "javascript",
		["text/ecmascript"] = "javascript",
	}

	local non_filetype_match_injection_language_aliases = {
		ex = "elixir",
		pl = "perl",
		sh = "bash",
		uxn = "uxntal",
		ts = "typescript",
	}

	local function first_node(value)
		if type(value) == "table" then
			return value[1]
		end
		return value
	end

	local function get_parser_from_markdown_info_string(injection_alias)
		local match = vim.filetype.match({ filename = "a." .. injection_alias })
		return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
	end

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = first_node(match[capture_id])
		if not node then
			return
		end

		local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[type_attr_value]
		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(type_attr_value, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, { force = true })

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = first_node(match[capture_id])
		if not node then
			return
		end

		local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
	end, { force = true })

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local id = pred[2]
		local node = first_node(match[id])
		if not node then
			return
		end

		local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
		if not metadata[id] then
			metadata[id] = {}
		end
		metadata[id].text = string.lower(text)
	end, { force = true })

	query.add_predicate("nth?", function(match, _, _, pred)
		local node = first_node(match[pred[2]])
		local n = tonumber(pred[3])
		if node and node:parent() and node:parent():named_child_count() > n then
			return node:parent():named_child(n) == node
		end
		return false
	end, { force = true })

	query.add_predicate("is?", function(match, _, bufnr, pred)
		local locals = require("nvim-treesitter.locals")
		local node = first_node(match[pred[2]])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		local _, _, kind = locals.find_definition(node, bufnr)
		return vim.tbl_contains(types, kind)
	end, { force = true })

	query.add_predicate("kind-eq?", function(match, _, _, pred)
		local node = first_node(match[pred[2]])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		return vim.tbl_contains(types, node:type())
	end, { force = true })
end
