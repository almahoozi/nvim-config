-- TODO: Use Lazy instead of Packer
local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer"
local install_path = packer_path .. "/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = vim.fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd.packadd("packer.nvim")
	if vim.fn.empty(vim.fn.glob(vim.fn.stdpath("config") .. ".packer-plugins")) > 0 then
		vim.fn.system({
			"ln",
			"-s",
			packer_path,
			vim.fn.stdpath("config") .. "/.packer-plugins",
		})
	end
end

local ag = vim.api.nvim_create_augroup("packer_sync", {})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = ag,
	pattern = "lua/user/plugins.lua",
	callback = function(ev)
		local choice = vim.fn.confirm("Source and sync?", "&Yes\n&No", 2)
		if choice ~= 1 then
			return
		end
		vim.cmd("source " .. ev.file)
		vim.cmd("PackerSync")
	end,
})

local ok, packer = pcall(require, "packer")
if not ok then
	return
end

packer.init({
	display = {
		preview_updates = true,
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	use({ "nvim-lua/plenary.nvim" })
	use({ "wbthomason/packer.nvim", requires = "nvim-lua/plenary.nvim" })

	use({ "nvim-telescope/telescope.nvim" })
	use({ "nvim-telescope/telescope-media-files.nvim" })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({ "nvim-treesitter/nvim-treesitter-context" })
	use({ "nvim-treesitter/playground" })

	use({ "nvim-tree/nvim-web-devicons" })

	use({
		"unblevable/quick-scope",
		config = function()
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
		end,
	})
	use({ "lukas-reineke/indent-blankline.nvim" }) -- FIX: Crashes with Dracula
	use({ "akinsho/bufferline.nvim" })
	use({ "kyazdani42/nvim-tree.lua", disable = true })
	use({ "windwp/nvim-autopairs" })
	use({ "p00f/nvim-ts-rainbow" })

	use({ "theprimeagen/harpoon" })
	use({ "mbbill/undotree" })
	use({ "tpope/vim-fugitive" })

	use({ "mg979/vim-visual-multi" })

	use({ "lewis6991/gitsigns.nvim" })
	use({ "ruifm/gitlinker.nvim" })

	use({ "nvimtools/none-ls.nvim" })

	use({ "catppuccin/nvim", as = "catppuccin" })
	use({ "folke/tokyonight.nvim", disable = true })
	use({ "Mofiqul/dracula.nvim", disable = true }) -- FIX: Crashes with indent-blankline

	use({ "numToStr/Comment.nvim" })
	use({ "JoosepAlviste/nvim-ts-context-commentstring" })
	use({ "moll/vim-bbye" })
	use({
		"nvim-lualine/lualine.nvim",
		disable = true,
	})
	use({ "akinsho/toggleterm.nvim" })
	use({ "ahmedkhalf/project.nvim" })
	use({ "lewis6991/impatient.nvim" })
	use({ "goolord/alpha-nvim" })

	use({ "williamboman/mason.nvim", run = "MasonUpdate" })
	use({ "williamboman/mason-lspconfig.nvim" })
	use({ "neovim/nvim-lspconfig" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-buffer" })
	use({ "L3MON4D3/LuaSnip" })
	use({ "rafamadriz/friendly-snippets" })
	use({ "hrsh7th/cmp-nvim-lua" })
	use({ "hrsh7th/cmp-path" })
	use({ "saadparwaiz1/cmp_luasnip" })

	use({ "RRethy/vim-illuminate" })

	use({
		"github/copilot.vim",
		config = function()
			vim.g.copilot_filetypes = {
				[""] = true,
				markdown = true,
				yaml = true,
			}
		end,
	})
	use({ "tpope/vim-surround" })
	use({ "airblade/vim-gitgutter", disable = true })
	use({ "vim-airline/vim-airline" })
	use({ "scrooloose/nerdcommenter" })
	use({ "majutsushi/tagbar" })
	use({ "kdheepak/lazygit.nvim", cmd = "LazyGit" })
	use({ "rmagatti/auto-session" })

	use({
		"rcarriga/nvim-dap-ui",
		requires = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
	})
	use({ "leoluz/nvim-dap-go" })
	use({ "theHamsta/nvim-dap-virtual-text" })

	use({ "stevearc/oil.nvim" })
	use({
		"stevearc/aerial.nvim",
		--disable = true,
		config = function()
			require("aerial").setup()
		end,
	})
	use({
		--disable = true,
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup()
		end,
	})
	use({
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup()
		end,
	})

	use({
		"rest-nvim/rest.nvim",
		-- v2.0.0 breaks fucking everything... I don't use this enough to care
		tag = "v1.2.1",
	})

	use({ "nvim-pack/nvim-spectre" })

	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	})

	-- use({ "folke/which-key.nvim" })
	-- use({ "folke/zen-mode.nvim" })
	-- use({ "folke/neodev.nvim" })
	use({
		"folke/todo-comments.nvim",
		event = "BufEnter",
		config = function()
			require("todo-comments").setup({
				signs = false,
				keywords = {
					WIP = {
						icon = "",
						color = "error",
						alt = { "IMP", "IMPL", "IMPLEMENT" },
					},
				},
			})
		end,
	})

	use({
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
		end,
	})

	use({
		"~/Documents/Source/personal/nvim/repl.nvim",
		-- "almahoozi/repl.nvim",
		config = function()
			require("repl").setup({
				Debug = true,
				Mappings = { Run = { "<leader><cr>" } },
			})
		end,
	})
	use({
		"~/Documents/Source/personal/nvim/notes.nvim",
		-- "almahoozi/notes.nvim",
		config = function()
			local notes = require("notes")
			notes.setup()
			vim.keymap.set("n", "<leader>n", notes.open_global, { noremap = true, silent = true })
		end,
	})

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
