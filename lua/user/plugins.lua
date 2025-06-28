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
		cmd = "Telescope",
		keys = {
			{ "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>ps", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		},
	},
	{ 
		"nvim-telescope/telescope-media-files.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
	},
	{ 
		"nvim-telescope/telescope-fzf-native.nvim", 
		build = "make",
		dependencies = { "nvim-telescope/telescope.nvim" },
	},

	-- Treesitter
	{ 
		"nvim-treesitter/nvim-treesitter", 
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
	},
	{ 
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
	},
	{ 
		"nvim-treesitter/playground",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
	},

	-- Icons
	{ "nvim-tree/nvim-web-devicons" },

	-- Movement and navigation
	{
		"unblevable/quick-scope",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
		end,
	},

	-- UI and visual enhancements
	{ 
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
	}, -- FIX: Crashes with Dracula
	{ 
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
	},
	{ 
		"kyazdani42/nvim-tree.lua", 
		enabled = false 
	},
	{ 
		"windwp/nvim-autopairs",
		event = "InsertEnter",
	},
	{ 
		"p00f/nvim-ts-rainbow",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
	},

	-- File management and navigation
	{ 
		"theprimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>a", function() require("harpoon.mark").add_file() end, desc = "Add file to harpoon" },
			{ "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Toggle harpoon menu" },
		},
	},
	{ 
		"mbbill/undotree",
		cmd = "UndotreeToggle",
	},
	{ 
		"tpope/vim-fugitive",
		cmd = { "Git", "G" },
	},
	{ 
		"stevearc/oil.nvim",
		cmd = "Oil",
	},

	-- Multi-cursor
	{ 
		"mg979/vim-visual-multi",
		event = { "BufReadPost", "BufNewFile" },
	},

	-- Git integration (moved from after/plugin/git.lua for proper loading order)
	{ 
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
				current_line_blame_opts = {
					delay = 300,
					-- ignore_whitespace = false,
				},
				-- word_diff  = true,
				on_attach = function(bufnr)
					-- local gs = require("gitsigns")
					local opts = { noremap = true, silent = true }
					local nm = function(...)
						vim.api.nvim_buf_set_keymap(bufnr, "n", ...)
					end
					nm("]c", ':lua require"gitsigns".next_hunk()<CR>', opts)
					nm("[c", ':lua require"gitsigns".prev_hunk()<CR>', opts)
					-- nm("<leader>ggb", ':lua require"gitsigns".blame_line()<CR>', opts)
					-- nm("<leader>q", ':lua require"gitsigns".reset_hunk()<CR>', opts)
					-- nm("<leader>Q", ':lua require"gitsigns".reset_buffer()<CR>', opts)
					nm("<leader>gp", ':lua require"gitsigns".preview_hunk()<CR>', opts)
					nm("<leader>gb", ':lua require"gitsigns".blame_line({full=true})<CR>', opts)
				end,
			})
		end,
	},
	{ 
		"ruifm/gitlinker.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitlinker").setup()
		end,
	},

	-- Formatting and linting
	{ 
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPre", "BufNewFile" },
	},

	-- Themes
	{ 
		"catppuccin/nvim", 
		name = "catppuccin",
		priority = 1000,
	},
	{ 
		"folke/tokyonight.nvim", 
		enabled = false 
	},
	{ 
		"Mofiqul/dracula.nvim", 
		enabled = false 
	}, -- FIX: Crashes with indent-blankline

	-- Comments
	{ 
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
	},
	{ 
		"JoosepAlviste/nvim-ts-context-commentstring",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = { "BufReadPost", "BufNewFile" },
	},
	{ 
		"scrooloose/nerdcommenter",
		event = { "BufReadPost", "BufNewFile" },
	},

	-- Buffer management
	{ 
		"moll/vim-bbye",
		cmd = { "Bdelete", "Bwipeout" },
	},

	-- Status line (disabled)
	{
		"nvim-lualine/lualine.nvim",
		enabled = false,
	},
	{ 
		"vim-airline/vim-airline",
		event = "VeryLazy",
	},

	-- Terminal
	{ 
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
	},

	-- Project management
	{ 
		"ahmedkhalf/project.nvim",
		event = "VeryLazy",
	},

	-- Performance
	{ 
		"lewis6991/impatient.nvim",
		priority = 1000,
	},

	-- Start screen
	{ 
		"goolord/alpha-nvim",
		event = "VimEnter",
	},

	-- LSP Configuration (fixed dependency chain and loading order)
	{ 
		"williamboman/mason.nvim", 
		build = ":MasonUpdate",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
				},
			})
		end,
	},
	{ 
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Ensure Mason is loaded first
			require("mason")
			
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
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Ensure dependencies are loaded
			require("mason")
			require("mason-lspconfig")
			
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
				
				-- Safely require telescope with fallback
				local has_telescope, telescope = pcall(require, "telescope.builtin")
				local has_themes, themes = pcall(require, "telescope.themes")
				
				if not (has_telescope and has_themes) then
					-- Fallback LSP mappings without telescope
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<leader>pd", vim.diagnostic.setloclist, opts)
				else
					-- Telescope-enhanced mappings
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
				end

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
				vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)
				vim.keymap.set({ "n", "v" }, "<A-.>", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "i" }, "<C-h>", vim.lsp.buf.signature_help, opts)
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
			local format_ag = vim.api.nvim_create_augroup("format_on_write", {})
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = format_ag,
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
			
			-- Setup protols manually
			local ok_protols, _ = pcall(function()
				lspconfig.protols.setup({
					on_attach = lsp_attach,
					capabilities = lsp_capabilities,
				})
			end)
			if not ok_protols then
				-- protols not available, skip
			end
			
			-- Setup handlers with error protection
			local ok_handlers, mason_lspconfig = pcall(require, "mason-lspconfig")
			if ok_handlers then
				mason_lspconfig.setup_handlers({
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
			else
				print("Mason-lspconfig not available for setup_handlers")
			end
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
		event = { "InsertEnter", "CmdlineEnter" },
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
	{ 
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
	},

	-- AI assistance
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = function()
			vim.g.copilot_filetypes = {
				[""] = true,
				markdown = true,
				yaml = true,
			}
		end,
	},

	-- Text objects and manipulation
	{ 
		"tpope/vim-surround",
		event = { "BufReadPost", "BufNewFile" },
	},

	-- Git gutter (disabled)
	{ 
		"airblade/vim-gitgutter", 
		enabled = false 
	},

	-- Tags
	{ 
		"majutsushi/tagbar",
		cmd = "TagbarToggle",
	},

	-- Git UI
	{ 
		"kdheepak/lazygit.nvim", 
		cmd = "LazyGit" 
	},

	-- Session management
	{ 
		"rmagatti/auto-session",
		event = "VimEnter",
	},

	-- Debug Adapter Protocol
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		cmd = { "DapUiToggle", "DapToggleBreakpoint" },
	},
	{ 
		"leoluz/nvim-dap-go",
		dependencies = { "mfussenegger/nvim-dap" },
		ft = "go",
	},
	{ 
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },
		event = { "BufReadPost", "BufNewFile" },
	},

	-- Additional tools
	{
		"stevearc/aerial.nvim",
		cmd = { "AerialToggle", "AerialOpen" },
		config = function()
			require("aerial").setup()
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		config = function()
			require("conform").setup()
		end,
	},
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			require("dressing").setup()
		end,
	},

	-- REST client
	{
		"rest-nvim/rest.nvim",
		-- v2.0.0 breaks fucking everything... I don't use this enough to care
		version = "v1.2.1",
		ft = { "http", "rest" },
	},

	-- Search and replace
	{ 
		"nvim-pack/nvim-spectre",
		cmd = { "Spectre", "SpectreToggle" },
	},

	-- LSP progress indicator
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		config = function()
			require("fidget").setup({})
		end,
	},

	-- TODO comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
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
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
		end,
	},

	-- Custom local plugins
	{
		dir = "~/Documents/Source/personal/nvim/repl.nvim",
		-- "almahoozi/repl.nvim",
		event = { "BufReadPost", "BufNewFile" },
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
		keys = { "<leader>n" },
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
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
