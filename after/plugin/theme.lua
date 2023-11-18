require("dracula").setup({
	show_end_of_buffer = true,
	italic_comment = true,
	overrides = function(colors)
		local highlights = require("dracula.groups").setup({ colors = colors })
		return {
			LspReferenceText = { bg = colors.selection },
			LspReferenceRead = { bg = colors.selection },
			LspReferenceWrite = { bg = colors.selection },
			IlluminatedWordText = { bg = colors.selection },
			IlluminatedWordRead = { bg = colors.selection },
			IlluminatedWordWrite = { bg = colors.selection },
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
		}
	end,
})

vim.cmd.colorscheme("dracula")
