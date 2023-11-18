local lsp = require("lsp-zero")
local util = require("lspconfig/util")
local cmp = require("cmp")

lsp.preset("recommended")

lsp.ensure_installed({
	"gopls",
	"lua_ls",
})

--local cmp_select = { behaviour = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	-- ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	-- ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	-- ['<C-y>'] = cmp.mapping.confirm({ select = true }),
	["<CR>"] = cmp.mapping.confirm({ select = true }),
	["<C-Space>"] = cmp.mapping.complete(),
})

lsp.set_sign_icons({
	error = "",
	warn = "",
	info = "",
	hint = "",
})

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
	preselect = true,
	formatting = {
		format = function(entry, vim_item)
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
			vim_item.kind = kind_icons[entry.kind]
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				nvim_lua = "[Lua]",
				buffer = "[BUF]",
				path = "[PATH]",
				calc = "[CALC]",
				vsnip = "[VSNIP]",
				nvim_treesitter = "[TS]",
			})[entry.source.name]
			if entry.source.name == "nvim_lsp" then
				vim_item.menu = "[" .. entry.source.source.client.name:upper() .. "]"
			end
			return vim_item
		end,
		fields = { "kind", "abbr", "menu" },
	},
})

-- disable completion with tab, this helps with copilot setup
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	--vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, opts)
	--vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	--vim.keymap.set("n", "<leader>vds", function() vim.lsp.buf.document_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set({ "n", "v", "x" }, "<leader>vca", function()
		vim.lsp.buf.code_action()
	end, opts)
	--vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vrn", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set({ "n", "i" }, "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)

	-- Use Telescope mappings for LSP for better experience; themes: ivy, dropdown, cursor, default (empty)
	vim.keymap.set("n", "gL", "<cmd>Telescope diagnostics theme=dropdown<cr>", opts)

	vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references theme=dropdown<cr>", opts)
	vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions theme=dropdown<cr>zt", opts)

	-- Get implementations shows with cursor them with 50% of the screen
	vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations theme=cursor layout_config={width=0.5}<cr>", opts)
	--vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations theme=cursor<cr>", opts)
	vim.keymap.set("n", "gD", "<cmd>Telescope lsp_type_definitions theme=dropdown<cr>", opts)
	vim.keymap.set("n", "<leader>o", "<cmd>Telescope lsp_document_symbols theme=ivy<cr>", opts)
	-- TODO: Cannot add a theme to this one
	-- Pass input as query and set theme to dropdown
	vim.keymap.set(
		"n",
		"<leader>t",
		"<cmd>lua require('telescope.builtin').lsp_workspace_symbols({query = vim.fn.input('Symbol: '), theme = require('telescope.themes').get_dropdown({ previewer = 10 })})<cr><C-r><C-w>",
		opts
	)
	vim.keymap.set("n", "]d", '<cmd>lua vim.diagnostic.goto_next({float = {source = "if_many"}})<cr>', opts)
	vim.keymap.set("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({float = {source = "if_many"}})<cr>', opts)

	-- if go, organize imports
	--if client.name == "gopls" then
	--vim.cmd [[ autocmd BufWritePre <buffer> lua OrganizeGoImports() ]]
	--end

	-- Format on save
	--vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
	-- Format on save
	vim.cmd([[autocmd BufWritePre <buffer> lua if not vim.b.no_format_on_save then vim.lsp.buf.format() end]])

	vim.cmd(
		[[ command! -buffer Save execute 'lua vim.b.no_format_on_save = true' | write | execute 'lua vim.b.no_format_on_save = false' ]]
	)
end)

function OrganizeGoImports(wait_ms)
	local params = vim.lsp.util.make_range_params()
	params.context = { only = { "source.organizeImports" } }
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
	for cid, res in pairs(result or {}) do
		for _, r in pairs(res.result or {}) do
			if r.edit then
				local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
				vim.lsp.util.apply_workspace_edit(r.edit, enc)
			end
		end
	end
end

require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

lsp.configure("gopls", {
	root_dir = util.root_pattern("go.work", "go.mod", ".git", "main.go"),
	filetypes = { "go", "gomod" },
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
})

lsp.configure("rust_analyzer", {
	root_dir = util.root_pattern("Cargo.toml", "rust-project.json", ".git", "main.rs"),
	filetypes = { "rust" },
})

--lsp.configure("csharp_ls", {
--root_dir = util.root_pattern("*.sln", ".git", "main.cs"),
--filetypes = { "cs", "csproj", "razor", "cshtml", "aspnetcorerazor" },
--})

lsp.nvim_workspace()
lsp.setup()

vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = "",
	},
	update_in_insert = true,
	severity_sort = true,
})
