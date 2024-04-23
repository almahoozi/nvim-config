local colorscheme = "catppuccin-macchiato"
local devicons = require("nvim-web-devicons").get_icons()
local function buffer_line_devicon_overrides(color)
	local overrides = {}
	for _, hl in pairs(devicons) do
		overrides["BufferLineDevIcon" .. hl.name] = { fg = color }
	end
	return overrides
end
local function with_devicon_overrides(color, table)
	local overrides = buffer_line_devicon_overrides(color)
	for name, hl in pairs(table) do
		overrides[name] = hl
	end
	return overrides
end

vim.g.default_colorscheme = colorscheme

require("catppuccin").setup({
	custom_highlights = function(colors)
		-- globals required in order to get the catppuccin highlights ¯\_(ツ)_/¯
		O = require("catppuccin").options
		C = require("catppuccin.palettes").get_palette("macchiato")
		U = require("catppuccin.utils.colors")
		local highlights = require("catppuccin.groups.syntax").get()
		local overrides = with_devicon_overrides(colors.overlay2, {
			LspReferenceText = { bg = colors.overlay2 },
			LspReferenceRead = { bg = colors.overlay2 },
			LspReferenceWrite = { bg = colors.overlay2 },
			IlluminatedWordText = { bg = colors.overlay2, standout = true },
			IlluminatedWordRead = { bg = colors.overlay2, standout = true },
			IlluminatedWordWrite = { bg = colors.overlay2, standout = true },
			TreesitterContext = { bg = colors.overlay2 },
			QuickScopePrimary = { fg = highlights.Function.fg, standout = true },
			QuickScopeSecondary = { fg = highlights.Define.fg, standout = true },
			TestPassed = { fg = colors.green },
			IndentBlanklineChar = { fg = colors.overlay2 },
			IblScope = { fg = "#ffffff" },
		})

		return overrides
	end,
})

-- FIXME: Dracula causes a crash with indent-blankline (ibl) in a strange way

--require("dracula").setup({
--show_end_of_buffer = true,
--italic_comment = true,
--overrides = function(colors)
--local highlights = require("dracula.groups").setup({ colors = colors })
--local overrides = with_devicon_overrides(colors.selection, {
--LspReferenceText = { bg = colors.selection },
--LspReferenceRead = { bg = colors.selection },
--LspReferenceWrite = { bg = colors.selection },
--IlluminatedWordText = { bg = colors.selection, standout = true },
--IlluminatedWordRead = { bg = colors.selection, standout = true },
--IlluminatedWordWrite = { bg = colors.selection, standout = true },
--TreesitterContext = { bg = colors.selection },
--QuickScopePrimary = { fg = highlights.Function.fg, standout = true },
--QuickScopeSecondary = { fg = highlights.Define.fg, standout = true },
--TestPassed = { fg = colors.green },
--Visual = { bg = "#993366" },
--IndentBlanklineChar = { fg = colors.selection },
--IblScope = { fg = colors.white },
--})

--return overrides
--end,
--})

--require("tokyonight").setup({
--on_highlights = function(highlights, colors)
--local overrides = buffer_line_devicon_overrides(colors.selection)
--for name, hl in pairs(overrides) do
--highlights[name] = hl
--end
--highlights.QuickScopePrimary = { fg = highlights.Function.fg, standout = true }
--highlights.QuickScopeSecondary = { fg = highlights.PreProc.fg, standout = true }
--highlights.TestPassed = { fg = colors.green }
--highlights.IndentBlanklineChar = { fg = colors.selection }
--highlights.IblScope = { fg = colors.white }
--end,
--})

vim.cmd.colorscheme(colorscheme)
