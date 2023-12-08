---@diagnostic disable: undefined-field, missing-fields
require("dracula").setup({
	show_end_of_buffer = true,
	italic_comment = true,
	overrides = function(colors)
		local highlights = require("dracula.groups").setup({ colors = colors })
		-- Need to dynamically find all BufferLineDevIcon* groups (excluding *Selected and *Inactive)
		-- and set their fg to colors.selection
		-- We can do this in an autocommand on BufEnter and get the group names with
		-- :so $VIMRUNTIME/syntax/hitest.vim
		-- We need to reappply the theme using dracula.load() after the autocommand

		local overrides = {
			LspReferenceText = { bg = colors.selection },
			LspReferenceRead = { bg = colors.selection },
			LspReferenceWrite = { bg = colors.selection },
			IlluminatedWordText = { bg = colors.selection, standout = true },
			IlluminatedWordRead = { bg = colors.selection, standout = true },
			IlluminatedWordWrite = { bg = colors.selection, standout = true },
			TreesitterContext = { bg = colors.selection },
			QuickScopePrimary = { fg = highlights.Function.fg, standout = true },
			QuickScopeSecondary = { fg = highlights.Define.fg, standout = true },
			TestPassed = { fg = colors.green },
			Visual = { bg = "#444444" },
			IndentBlanklineChar = { fg = colors.selection },
			IblScope = { fg = colors.white },
			BufferLineDevIconGo = { fg = colors.selection },
			BufferLineDevIconLua = { fg = colors.selection },
			BufferLineDevIconDefault = { fg = colors.selection },
			BufferLineDevIconEnv = { fg = colors.selection },
			BufferLineDevIconYml = { fg = colors.selection },
			BufferLineDevIconJson = { fg = colors.selection },
			BufferLineDevIconJs = { fg = colors.selection },
			BufferLineDevIconGitIgnore = { fg = colors.selection },
			BufferLineDevIconC = { fg = colors.selection },
			BufferLineDevIconCpp = { fg = colors.selection },
			BufferLineDevIconMd = { fg = colors.selection },
			BufferLineDevIconTerraform = { fg = colors.selection },
			BufferLineDevIconZsh = { fg = colors.selection },
			BufferLineDevIconMakefile = { fg = colors.selection },
		}

		return overrides
	end,
})

vim.cmd.colorscheme("dracula")
