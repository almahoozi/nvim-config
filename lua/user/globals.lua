vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- TODO: Move to vim-visual-multi config
vim.g.VM_leader = "\\" -- Leader for Vim Multi Line plugin

-- TODO: Move to copilot config
-- Enable internally disabled copilot filetypes
vim.g.copilot_filetypes = {
	[""] = true,
	markdown = true,
	yaml = true,
}

-- TODO: Move to QuickScope config; it is not working unless it is set here
vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }

-- No longer using netrw
vim.g.netrw_banner = 0
vim.g.netrw_preview = 1
vim.g.netrw_alto = 0
vim.g.netrw_winsize = 30
