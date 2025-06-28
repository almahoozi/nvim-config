-- Migrated from Packer.nvim to Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Auto-sync on plugin file changes
local ag = vim.api.nvim_create_augroup("lazy_sync", {})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = ag,
	pattern = "lua/user/plugins.lua",
	callback = function(ev)
		local choice = vim.fn.confirm("Source and sync?", "&Yes\n&No", 2)
		if choice ~= 1 then
			return
		end
		vim.cmd("source " .. ev.file)
		require("lazy").sync()
	end,
})

require("lazy").setup({
	-- Core dependencies
	{ "nvim-lua/plenary.nvim" },

	-- Telescope and extensions
	{ 
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ "nvim-telescope/telescope-media-files.nvim" },
	{ 
		"nvim-telescope/telescope-fzf-native.nvim", 
		build = "make" 
	},

	-- Treesitter
	{ 
		"nvim-treesitter/nvim-treesitter", 
		build = ":TSUpdate" 
	},
	{ "nvim-treesitter/nvim-treesitter-context" },
	{ "nvim-treesitter/playground" },

	-- Icons
	{ "nvim-tree/nvim-web-devicons" },

	-- Movement and navigation
	{
		"unblevable/quick-scope",
		config = function()
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
		end,
	},

	-- UI and visual enhancements
	{ "lukas-reineke/indent-blankline.nvim" }, -- FIX: Crashes with Dracula
	{ "akinsho/bufferline.nvim" },
	{ 
		"kyazdani42/nvim-tree.lua", 
		enabled = false 
	},
	{ "windwp/nvim-autopairs" },
	{ "p00f/nvim-ts-rainbow" },

	-- File management and navigation
	{ "theprimeagen/harpoon" },
	{ "mbbill/undotree" },
	{ "tpope/vim-fugitive" },
	{ "stevearc/oil.nvim" },

	-- Multi-cursor
	{ "mg979/vim-visual-multi" },

	-- Git integration
	{ "lewis6991/gitsigns.nvim" },
	{ "ruifm/gitlinker.nvim" },

	-- Formatting and linting
	{ "nvimtools/none-ls.nvim" },

	-- Themes
	{ "catppuccin/nvim", name = "catppuccin" },
	{ 
		"folke/tokyonight.nvim", 
		enabled = false 
	},
	{ 
		"Mofiqul/dracula.nvim", 
		enabled = false 
	}, -- FIX: Crashes with indent-blankline

	-- Comments
	{ "numToStr/Comment.nvim" },
	{ "JoosepAlviste/nvim-ts-context-commentstring" },
	{ "scrooloose/nerdcommenter" },

	-- Buffer management
	{ "moll/vim-bbye" },

	-- Status line (disabled)
	{
		"nvim-lualine/lualine.nvim",
		enabled = false,
	},
	{ "vim-airline/vim-airline" },

	-- Terminal
	{ "akinsho/toggleterm.nvim" },

	-- Project management
	{ "ahmedkhalf/project.nvim" },

	-- Performance
	{ "lewis6991/impatient.nvim" },

	-- Start screen
	{ "goolord/alpha-nvim" },

	-- LSP Configuration (moved from after/plugin/lsp.lua for proper loading order)
	{ 
		"williamboman/mason.nvim", 
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{ 
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
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
					"ts_ls",
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
		end,
	},
	{ 
		"neovim/nvim-lspconfig",
		dependencies = { 
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- This replaces the content from after/plugin/lsp.lua
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

			-- Diagnostic signs
			local sign = function(opts)
				vim.fn.sign_define(opts.name, { texthl = opts.name, text = opts.text, numhl = "" })
			end

			sign({ name = "DiagnosticSignError", text = "" })
			sign({ name = "DiagnosticSignWarn", text = "" })
			sign({ name = "DiagnosticSignHint", text = "" })
			sign({ name = "DiagnosticSignInfo", text = "" })

			vim.diagnostic.config({
				virtual_text = { spacing = 4, prefix = "" },
				update_in_insert = true,
				severity_sort = true,
				float = { border = "rounded" },
			})

			-- Round them corners
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

			-- Format on save
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
			lspconfig.protols.setup({}) -- cargo install protols from: https://github.com/coder3101/protols
			
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
		end,
	},

	-- Completion
	{ "hrsh7th/cmp-nvim-lsp" },
	{ 
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
		},
		config = function()
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
							Text = "",
							Method = "ƒ",
							Function = "",
							Constructor = "",
							Field = "ﰠ",
							Variable = "",
							Class = "",
							Interface = "ﰮ",
							Module = "",
							Property = "",
							Unit = "",
							Value = "",
							Enum = "了",
							Keyword = "",
							Snippet = "﬌",
							Color = "",
							File = "",
							Reference = "",
							Folder = "",
							EnumMember = "",
							Constant = "",
							Struct = "",
							Event = "",
							Operator = "",
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
		end,
	},
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-nvim-lua" },
	{ "hrsh7th/cmp-path" },
	{ "saadparwaiz1/cmp_luasnip" },

	-- Snippets
	{ "L3MON4D3/LuaSnip" },
	{ "rafamadriz/friendly-snippets" },

	-- Code highlighting and navigation
	{ "RRethy/vim-illuminate" },

	-- AI assistance
	{
		"github/copilot.vim",
		config = function()
			vim.g.copilot_filetypes = {
				[""] = true,
				markdown = true,
				yaml = true,
			}
		end,
	},

	-- Text objects and manipulation
	{ "tpope/vim-surround" },

	-- Git gutter (disabled)
	{ 
		"airblade/vim-gitgutter", 
		enabled = false 
	},

	-- Tags
	{ "majutsushi/tagbar" },

	-- Git UI
	{ 
		"kdheepak/lazygit.nvim", 
		cmd = "LazyGit" 
	},

	-- Session management
	{ "rmagatti/auto-session" },

	-- Debug Adapter Protocol
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
	},
	{ "leoluz/nvim-dap-go" },
	{ "theHamsta/nvim-dap-virtual-text" },

	-- Additional tools
	{
		"stevearc/aerial.nvim",
		config = function()
			require("aerial").setup()
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup()
		end,
	},
	{
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup()
		end,
	},

	-- REST client
	{
		"rest-nvim/rest.nvim",
		-- v2.0.0 breaks fucking everything... I don't use this enough to care
		version = "v1.2.1",
	},

	-- Search and replace
	{ "nvim-pack/nvim-spectre" },

	-- LSP progress indicator
	{
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	},

	-- TODO comments
	{
		"folke/todo-comments.nvim",
		event = "BufEnter",
		config = function()
			require("todo-comments").setup({
				signs = false,
				keywords = {
					IDEA = {
						icon = "",
						color = "info",
					},
					WIP = {
						icon = "",
						color = "error",
						alt = { "IMP", "IMPL", "IMPLEMENT" },
					},
				},
				search = {
					command = "rg",
					args = {
						"--hidden",
						"-g",
						"!.git",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
				},
			})
		end,
	},

	-- Mini.nvim collection
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
		end,
	},

	-- Custom local plugins
	{
		dir = "~/Documents/Source/personal/nvim/repl.nvim",
		-- "almahoozi/repl.nvim",
		config = function()
			require("repl").setup({
				Debug = true,
				Mappings = { Run = { "<leader><cr>" } },
			})
		end,
	},
	{
		dir = "~/Documents/Source/personal/nvim/notes.nvim",
		-- "almahoozi/notes.nvim",
		config = function()
			local notes = require("notes")
			notes.setup()
			vim.keymap.set("n", "<leader>n", notes.open_global, { noremap = true, silent = true })
		end,
	},

	-- Commented out plugins (originally disabled or commented)
	-- { "folke/which-key.nvim" },
	-- { "folke/zen-mode.nvim" },
	-- { "folke/neodev.nvim" },
}, {
	-- Lazy.nvim configuration options
	ui = {
		border = "rounded",
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
})
