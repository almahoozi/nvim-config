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

	-- LSP
	{ 
		"williamboman/mason.nvim", 
		build = ":MasonUpdate" 
	},
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },

	-- Completion
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/nvim-cmp" },
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
