-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/#snippets
-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#you-might-not-need-lsp-zero
-- TODO: Configure DAP, Linting, Formattings as well
-- TODO: Do what Null-LS does since it is deprecated
-- Use aucmd if not using mason-lspconfig's setup_handlers callback
--[[
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local name = vim.lsp.get_client_by_id(ev.data.client_id).name
		local bufnr = ev.buf
		local ok, keymaps = pcall(require, "lsp." .. name)
		if ok then
			if type(keymaps) ~= "table" or (keymaps.keymaps and type(keymaps.keymaps) ~= "function") then
				print("Error loading keymaps for " .. name)
				print(
					"LSP specific keymaps must be returned in an exposed `keymaps(bufnr)` function in a Lua module under 'lua/lsp/' with the name matching the LSP Server's name, for example 'lua_ls.lua' (or 'lua_ls/init.lua')"
				)
			end

			ok, keymaps = pcall(keymaps.keymaps, bufnr)
			if not ok then
				local err = keymaps
				print("Error setting keymaps for " .. name .. ": " .. err)
			end
		end
	end,
})
--]]
require("mason").setup()
require("mason-lspconfig").setup({
	automatic_installation = true,
	ensure_installed = {
		-- TODO: Source list of installations from their respective configuration dirs
		"asm_lsp",
		"bashls", -- "shfmt",
		"clangd",
		-- "black",
		"pyright", -- "delve",
		-- "goimports",
		"golangci_lint_ls",
		"gopls",
		"templ",
		"docker_compose_language_service",
		-- "dockerfilels",

		"cssls",
		"eslint",
		"html",
		"htmx",
		"tsserver",
		"jsonls",
		"taplo",
		"yamlls",
		"lua_ls", -- "stylua",
		-- "markdownlint",
		"marksman", -- "prettierd",
		"rust_analyzer", -- "sql_formatter",
		-- "sqlfmt",
		"sqlls",
		"terraformls",
		"tflint",
		"vimls",
	},
})

local cmp = require("cmp")
local luasnip = require("luasnip")

-- Really?
require("luasnip.loaders.from_vscode").lazy_load()

-- https://github.com/LuaLS/lua-language-server/issues/2214#issuecomment-1685224510
---@diagnostic disable: missing-fields
cmp.setup({
	mapping = {
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<A-.>"] = cmp.mapping.complete(),
		["<Esc>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.abort()
			end
			fallback()
		end),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = "select" }),
		["<C-j>"] = cmp.mapping(function(_)
			if cmp.visible() then
				cmp.select_next_item({ behavior = "insert" })
			else
				cmp.complete()
			end
		end),
		["<C-k>"] = cmp.mapping(function(_)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = "insert" })
			else
				cmp.complete()
			end
		end),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "nvim_lua" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "path" },
		{ name = "luasnip", keyword_length = 2 },
	},
	window = {
		documentation = cmp.config.window.bordered(),
		completion = cmp.config.window.bordered(),
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, item)
			local kind_icons = {
				Text = "",
				Method = "ƒ",
				Function = "",
				Constructor = "",
				Field = "ﰠ",
				Variable = "",
				Class = "",
				Interface = "ﰮ",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "了",
				Keyword = "",
				Snippet = "﬌",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = "T",
			}

			local lsp_name = "LSP"
			local client = entry.source.source.client
			if client ~= nil then
				lsp_name = client.name:upper()
			end

			local menu_text = {
				nvim_lsp = "[" .. lsp_name .. "]",
				luasnip = "[Lua]",
				buffer = "[BUF]",
			}

			local completion_kinds = require("cmp.types.lsp").CompletionItemKind
			local kind = ""
			for k, v in pairs(completion_kinds) do
				if v == entry.completion_item.kind then
					kind = k
					break
				end
			end
			item.kind = kind_icons[kind] or kind
			item.menu = menu_text[entry.source.name] or entry.source.name:gsub("_", ""):upper()
			return item
		end,
	},
})

local sign = function(opts)
	vim.fn.sign_define(opts.name, { texthl = opts.name, text = opts.text, numhl = "" })
end

sign({ name = "DiagnosticSignError", text = "" })
sign({ name = "DiagnosticSignWarn", text = "" })
sign({ name = "DiagnosticSignHint", text = "" })
sign({ name = "DiagnosticSignInfo", text = "" })

vim.diagnostic.config({
	virtual_text = { spacing = 4, prefix = "" },
	update_in_insert = true,
	severity_sort = true,
	float = { border = "rounded" },
})

-- Round them corners
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_attach = function(client, bufnr)
	local name = client.name
	local ok, lsp_on_attach = pcall(require, "lsp." .. name)
	if ok then
		if type(lsp_on_attach) ~= "table" or (lsp_on_attach.handler and type(lsp_on_attach.handler) ~= "function") then
			print("Error loading keymaps for " .. name)
			print(
				"LSP specific on_attach handlers must be returned in an exposed `handler(bufnr)` function in a Lua module under 'lua/lsp/' with the name matching the LSP Server's name, for example 'lua_ls.lua' (or 'lua_ls/init.lua')"
			)
		end

		if lsp_on_attach.handler then
			local attached, handler = pcall(lsp_on_attach.handler, bufnr)
			if not attached then
				local err = handler
				print("Error setting keymaps for " .. name .. ": " .. err)
			end
		end
	end

	local opts = { buffer = bufnr, noremap = true, silent = true }
	local telescope = require("telescope.builtin")
	local themes = require("telescope.themes")

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)
	vim.keymap.set({ "n", "v" }, "<A-.>", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
	vim.keymap.set({ "n", "i" }, "<C-h>", vim.lsp.buf.signature_help, opts)
	-- TODO: Consolidate with telescope.lua mappings
	vim.keymap.set("n", "gr", function()
		telescope.lsp_references(themes.get_dropdown())
	end, opts)
	vim.keymap.set("n", "gd", function()
		telescope.lsp_definitions(themes.get_dropdown())
	end, opts)
	vim.keymap.set("n", "gt", function()
		telescope.lsp_type_definitions(themes.get_dropdown())
	end, opts)
	vim.keymap.set("n", "gi", function()
		telescope.lsp_implementations(themes.get_cursor({
			layout_config = { width = 0.5 },
		}))
	end, opts)
	vim.keymap.set("n", "<leader>o", function()
		telescope.lsp_document_symbols(themes.get_ivy())
	end, opts)
	vim.keymap.set("n", "<leader>t", function()
		telescope.lsp_workspace_symbols(themes.get_ivy())
	end, opts)
	vim.keymap.set("n", "<leader>pd", function()
		telescope.diagnostics(themes.get_dropdown())
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_next({ float = { source = "if_many" } })
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_prev({ float = { source = "if_many" } })
	end, opts)
end

-- If setup_handlers doesn't work as expected, manually loop instead
--[[
  local get_servers = require('mason-lspconfig').get_installed_servers

  for _, server_name in ipairs(get_servers()) do
    lspconfig[server_name].setup({
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
    })
  end
--]]

local ag = vim.api.nvim_create_augroup("format_on_write", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = ag,
	pattern = "*",
	callback = function(_)
		if vim.b.skip_format then
			return
		end
		vim.cmd("lua vim.lsp.buf.format()")
	end,
})
vim.api.nvim_create_user_command("Save", function()
	vim.b.skip_format = true
	vim.cmd("write")
	vim.b.skip_format = false
end, {})

local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
	function(name)
		local ok, config = pcall(require, "lsp." .. name)
		if ok then
			if type(config) ~= "table" or not config.config then
				print("Error loading config for " .. name)
				print(
					"LSP specific configs must be returned in an exposed `config()` function (or `config` table) in a Lua module under 'lua/lsp/' with the name matching the LSP Server's name, for example 'lua_ls.lua' (or 'lua_ls/init.lua')"
				)
				print("Using default config")
				ok = false
			elseif type(config.config) == "function" then
				ok, config = pcall(config.config)
				if not ok then
					local err = config
					print("Error loading config for " .. name .. ": " .. err)
					print("Using default config")
				end
			elseif type(config.config) == "table" then
				config = config.config
			else
				print(
					"Error loading config for "
						.. name
						.. ": config cannot be of type "
						.. type(config.config)
						.. "; it must be either a function returning a table, or a table itself"
				)
				print("Using default config")
				ok = false
			end
		end

		if not ok then
			config = {}
		end

		if not config.on_attach then
			config.on_attach = lsp_attach
		end

		if not config.capabilities then
			config.capabilities = lsp_capabilities
		end

		lspconfig[name].setup(config)
	end,
})
