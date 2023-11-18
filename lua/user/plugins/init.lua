-- TODO: Clean up
-- TODO: Use lua where possible
-- TODO: Get rid of LSPZero and utilize native LSP
-- TODO: Use Lazy instead of Packer
-- TODO: Canonicalize Mason's installs
-- TODO: Ask before PackerSyncing on write

-- TODO: Can't we just use vim.cmd.packadd("packer.nvim")?
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
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
end

vim.cmd([[
augroup packer_src_n_sync_on_write
autocmd!
autocmd BufWritePost lua/user/plugins/init.lua source <afile> | PackerSync
augroup end
]])

local ok, packer = pcall(require, "packer")
if not ok then
	print("Error loading packer: " .. packer)
	return
end

packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	use({ "wbthomason/packer.nvim", requires = "nvim-lua/plenary.nvim" })

	use({ "nvim-telescope/telescope.nvim" })
	use({ "nvim-telescope/telescope-media-files.nvim" })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({ "nvim-treesitter/nvim-treesitter-context" })

	use({ "kyazdani42/nvim-web-devicons" })

	use({ "unblevable/quick-scope" })
	use({ "lukas-reineke/indent-blankline.nvim" })
	use({ "akinsho/bufferline.nvim" })
	use({ "kyazdani42/nvim-tree.lua" })
	use({ "windwp/nvim-autopairs" })
	use({ "p00f/nvim-ts-rainbow" })

	use({ "theprimeagen/harpoon" })
	use({ "mbbill/undotree" })
	use({ "tpope/vim-fugitive" })

	use({ "mg979/vim-visual-multi", branch = "master" })

	use({ "lewis6991/gitsigns.nvim" })
	use({ "ruifm/gitlinker.nvim" })

	use({ "jose-elias-alvarez/null-ls.nvim" }) -- deprecated

	use({ "Mofiqul/dracula.nvim" })

	use({ "numToStr/Comment.nvim" })
	use({ "JoosepAlviste/nvim-ts-context-commentstring" })
	use({ "moll/vim-bbye" })
	use({ "nvim-lualine/lualine.nvim" })
	use({ "akinsho/toggleterm.nvim" })
	use({ "ahmedkhalf/project.nvim" })
	use({ "lewis6991/impatient.nvim" })
	use({ "goolord/alpha-nvim" })
	-- use({ "folke/which-key.nvim" })

	-- TODO: Get rid of LSPZero
	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{
				"williamboman/mason.nvim",
				run = function()
					vim.cmd("MasonUpdate")
				end,
			},
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})

	use({ "RRethy/vim-illuminate" })

	use({ "github/copilot.vim" })
	use({ "tpope/vim-surround" })
	use({ "airblade/vim-gitgutter" })
	use({ "vim-airline/vim-airline" })
	use({ "scrooloose/nerdcommenter" })
	use({ "Djancyp/better-comments.nvim" })
	use({ "majutsushi/tagbar" })
	use({
		"kdheepak/lazygit.nvim",
		cmd = "LazyGit",
	})
	use({ "rmagatti/auto-session" })

	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
	use({ "leoluz/nvim-dap-go" })
	use({ "theHamsta/nvim-dap-virtual-text" })

	use({ "stevearc/oil.nvim" })

	use({ "rest-nvim/rest.nvim" })

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
