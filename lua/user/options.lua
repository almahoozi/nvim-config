vim.opt.clipboard = "unnamedplus"

vim.opt.title = true
vim.opt.showmode = false
vim.opt.conceallevel = 0
vim.opt.cmdheight = 1
vim.opt.showtabline = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.fileencoding = "utf-8"

vim.opt.completeopt = { "menuone", "noselect", "preview" }
vim.opt.pumheight = 10

vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.hlsearch = true -- Aucmd: Esc to disable, autocmd / ? to re-enable
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.swapfile = false
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.undofile = true

vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.cursorline = true

vim.opt.linebreak = true
vim.opt.showbreak = "↳ "
vim.opt.colorcolumn = "80"
vim.opt.wrap = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"

vim.opt.termguicolors = true
vim.opt.guicursor = "i:blinkon1"

vim.opt.whichwrap = "bs<>[]hl"
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,options"

vim.opt.mouse = "" -- disallow the mouse to be used in neovim

-- The tabs take over indent line, and they don't even show within the line, just before
--vim.opt.list = false
vim.opt.listchars = {
	tab = "▸ ",
	trail = "•",
}

vim.opt.shortmess:append("mrc")
vim.opt.iskeyword:append("-")

-- TODO: Is 'remove' valid? This is a string and afaik `remove` only operates on tables
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- separate vim plugins from neovim in case vim still in use

vim.opt.langmap:append("§`")
vim.opt.langmap:append("±~")
-- "translate" keys in normal mode for different languages
-- Note this isn't perfect but allows the majority of single character keymaps
-- to work without having to switch to a different keyboard layout between
-- normal and insert mode. Multicharacter keymaps are not supported sadly.
-- Nor is this useful for command mode.
for _, lang in pairs({ "ar" }) do
	local ok, _ = pcall(function()
		require("user.langmap_" .. lang .. "_options")
	end)
	if not ok then
		print("No langmap options found for " .. lang)
	end
end
