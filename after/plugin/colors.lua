-- Initialization of global variables
vim.g.transparency_toggle = false
vim.g.normal_background = nil
vim.g.normalfloat_background = nil

local ns = 0
local initialized = false

function ToggleTransparency(color)
	local default_color = vim.g.default_colorscheme
	color = color or default_color
	vim.cmd.colorscheme(color)

	if not initialized then
		SaveBackgroundColors()
		initialized = true
	end

	if vim.g.transparency_toggle then
		-- Use default background color
		vim.api.nvim_set_hl(ns, "Normal", { bg = vim.g.normal_background })
		vim.api.nvim_set_hl(ns, "NormalFloat", { bg = vim.g.normalfloat_background })
	else
		-- Make background transparent
		vim.api.nvim_set_hl(ns, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(ns, "NormalFloat", { bg = "none" })
	end

	vim.g.transparency_toggle = not vim.g.transparency_toggle

	vim.cmd(
		"autocmd BufEnter * lua vim.api.nvim_set_hl("
			.. ns
			.. ', "Normal", { bg = vim.g.transparency_toggle and "none" or vim.g.normal_background})'
	)
	vim.cmd(
		"autocmd BufEnter * lua vim.api.nvim_set_hl("
			.. ns
			.. ', "NormalFloat", { bg = vim.g.transparency_toggle and "none" or vim.g.normalfloat_background})'
	)
end

-- Key mapping
vim.api.nvim_set_keymap("n", "<leader>tt", ":lua ToggleTransparency()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>rr",
	":lua ToggleTransparency()<CR>:lua ToggleTransparency()<CR>",
	{ noremap = true, silent = true }
)

-- Call this function after setting up your colorscheme
function SaveBackgroundColors()
	vim.g.normal_background = vim.api.nvim_get_hl(ns, { name = "Normal", link = false }).bg
	vim.g.normalfloat_background = vim.api.nvim_get_hl(ns, { name = "NormalFloat", link = false }).bg
end
