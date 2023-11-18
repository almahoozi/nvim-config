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

--[[
vim.opt.mouse = "" -- disallow the mouse to be used in neovim
--]]

vim.opt.shortmess:append("mrc")
vim.opt.iskeyword:append("-")

-- TODO: Is 'remove' valid? This is a string and afaik `remove` only operates on tables
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- separate vim plugins from neovim in case vim still in use
