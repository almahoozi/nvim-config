vim.cmd.packadd("packer.nvim")

return require("packer").startup(function(use)
  use("wbthomason/packer.nvim")

  use({
    "nvim-telescope/telescope.nvim",
    tag = "0.1.x",
    requires = { { "nvim-lua/plenary.nvim" } },
  })

  use({ "nvim-telescope/telescope-media-files.nvim" })
  require("telescope").load_extension("media_files")
  require("telescope").setup({
    extensions = {
      media_files = {
        filetypes = { "png", "jpeg", "jpg", "webm", "webp" },
      },
    },
  })

  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  require("telescope").load_extension("fzf")

  use("nvim-tree/nvim-web-devicons")

  use({ "Mofiqul/dracula.nvim" })
  local dracula = require("dracula")
  dracula.setup({
    -- show the '~' characters after the end of buffers
    show_end_of_buffer = true,
    -- set italic comment
    italic_comment = true,
    -- overrides the default highlights see `:h synIDattr`leo
    overrides = {
      LspReferenceText = { bg = dracula.colors().selection },
      LspReferenceRead = { bg = dracula.colors().selection },
      LspReferenceWrite = { bg = dracula.colors().selection },
      TreesitterContext = { bg = dracula.colors().selection },
      -- QuickScope; fg is hardcoded to values of Function & Define since
      -- the groups are not defined yet in the overrides scope
      QuickScopePrimary = { fg = dracula.colors().yellow, underline = true },
      QuickScopeSecondary = { fg = dracula.colors().purple, underline = true },
      TestPassed = { fg = dracula.colors().green },
      Visual = {
        bg = "#444444",
      },
    },
  })
  vim.cmd.colorscheme("dracula")

  use({
    "unblevable/quick-scope",
    config = function()
      vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
      -- The highlight background color should stand out from the rest of the text
      -- we are underlining it in the theme setup
    end,
  })
  --use { "folke/which-key.nvim" }
  use({ "lukas-reineke/indent-blankline.nvim" })
  --use "goolord/alpha-nvim";
  --require("alpha").setup(require("alpha.themes.startify").opts)
  use({ "akinsho/bufferline.nvim" })
  require("bufferline").setup({})
  use({ "kyazdani42/nvim-tree.lua" })
  --require("nvim-tree").setup()
  use({ "windwp/nvim-autopairs" })
  require("nvim-autopairs").setup({
    disable_filetype = { "TelescopePrompt", "vim" },
    check_ts = true,
  })

  use({ "jose-elias-alvarez/null-ls.nvim" })
  local fmt = require("null-ls").builtins.formatting
  local diag = require("null-ls").builtins.diagnostics
  require("null-ls").setup({
    sources = {
      fmt.stylua,
      fmt.markdownlint,
      fmt.prettierd,
      fmt.eslint_d,
      fmt.black,
      fmt.shfmt,
      fmt.sqlformat,
      fmt.gofmt,
      fmt.goimports,
      fmt.rustfmt,
      fmt.lua_format,
      diag.golangci_lint,
    },
  })

  use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
  use("nvim-treesitter/nvim-treesitter-context")
  use("p00f/nvim-ts-rainbow")
  -- use('nvim-treesitter/playground')
  use("theprimeagen/harpoon")
  use("mbbill/undotree")
  use("tpope/vim-fugitive")
  use({ "mg979/vim-visual-multi", branch = "master" })

  use({ "lewis6991/gitsigns.nvim" })

  use({
    "ruifm/gitlinker.nvim",
    requires = "nvim-lua/plenary.nvim",
  })

  use({
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
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
      -- Snippet Collection (Optional)
      { "rafamadriz/friendly-snippets" },
    },
  })

  use("mfussenegger/nvim-dap")
  use("leoluz/nvim-dap-go")
  require("dap-go").setup()
  use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
  require("dapui").setup()
  local dap, dapui = require("dap"), require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  -- set up dap for rust and dotnet
  use("theHamsta/nvim-dap-virtual-text")

  use("mfussenegger/nvim-jdtls")

  use({ "github/copilot.vim" })
  --, config = function()
  --require('copilot').setup()
  --end }

  use("tpope/vim-surround")
  use("airblade/vim-gitgutter")
  use("vim-airline/vim-airline")
  use("scrooloose/nerdcommenter")
  use("majutsushi/tagbar")
  use("Djancyp/better-comments.nvim")
  require("better-comment").Setup({
    tags = {
      {
        name = "!",
        fg = "#FF2D00",
        bg = dracula.colors().bg,
        bold = false,
      },
      {
        name = "?",
        fg = "#3498DB",
        bg = dracula.colors().bg,
        bold = false,
      },
      {
        name = "TODO",
        fg = "#FF8C00",
        bg = dracula.colors().bg,
        bold = false,
      },
    },
  })

  use({
    "akinsho/toggleterm.nvim",
    tag = "*",
    config = function()
      require("toggleterm").setup()
    end,
  })
  -- // Install lazygit
  use({
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    config = function()
      require("lazygit").setup({})
    end,
  })

  --use({
  --"folke/flash.nvim",
  --config = function()
  --require("flash").setup({})
  --end,
  --})
  --use({ "fatih/vim-go", run = ":GoUpdateBinaries" })
  use({
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
        auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir()
            or vim.loop.cwd() == vim.loop.os_homedir() .. "/Documents/Source",
      })
    end,
  })
end)
