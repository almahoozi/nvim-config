local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function names
local keymap = vim.api.nvim_set_keymap

-- n = normal
local nm = function(...)
	keymap("n", ...)
end
-- i = insert
local im = function(...)
	keymap("i", ...)
end
-- v = visual
local vm = function(...)
	keymap("v", ...)
end
-- t = terminal
local tm = function(...)
	keymap("t", ...)
end
-- x = visual
local xm = function(...)
	keymap("x", ...)
end

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.VM_leader = "\\" -- Leader for Vim Multi Line plugin

--nm("<C-w><C-n><C-v>", ":vne<CR>", opts) -- Open vertical split
-- Normal --
-- Open directory explorer
--nm("<leader>pv", ":Explore<cr>", opts)
nm("<leader>pv", ":Oil<cr>", opts)

-- Window navigation
nm("<leader>h", "<C-w>h", opts)
nm("<leader>j", "<C-w>j", opts)
nm("<leader>k", "<C-w>k", opts)
nm("<leader>l", "<C-w>l", opts)
nm("<leader>wv", "<C-w>v", opts)
nm("<leader>ws", "<C-w>s", opts)

-- Swap 0 and ^ (home and first non-blank character)
nm("0", "^", opts)
nm("^", "0", opts)

nm("gg", "gg^", opts) -- Go to start of the first line
nm("G", "G$", opts) -- Go to end of the last line

-- Function navigation tailored for Go
-- TODO: Add only to buffers with filetype go
nm("[[", "^?^func<CR>zz", opts) -- Go to the start of the previous function or method
nm("]]", "/^func<CR>zz", opts) -- Go to the start of the next function or method
nm("]f", "/^func\\s*\\w<CR>zz", opts) -- Go to the start of the next function
nm("[f", "^?^func\\s*\\w<CR>zz", opts) -- Go to the start of the previous function
nm("[m", "^?^func\\s*(<CR>zz", opts) -- Go to the start of the previous method
nm("]m", "/^func\\s*(<CR>zz", opts) -- Go to the start of the next method

-- Save and source file
nm("<leader><leader>x", ":w<CR>:source %<CR>", opts)

-- Resize with arrows
nm("<A-Up>", ":resize +2<CR>", opts)
nm("<A-Down>", ":resize -2<CR>", opts)
nm("<A-->", ":vertical resize -1<CR>", opts) -- Mappped to something else
nm("<A-=>", ":vertical resize +2<CR>", opts) -- Mappped to something else

-- Navigate buffers
nm("<S-l>", ":bnext<CR>", opts)
nm("<S-h>", ":bprevious<CR>", opts)

-- Move line up and down and indent
nm("<A-j>", ":move .+1<CR>==", opts)
nm("<A-k>", ":move .-2<CR>==", opts)

nm("J", "mzJ`z", opts) -- Join lines without moving cursor
nm("<C-d>", "<C-d>zz", opts) -- Scroll down half a page keeping cursor in the middle
nm("<C-u>", "<C-u>zz", opts) -- Scroll up half a page keeping cursor in the middle
nm("<C-f>", "<C-f>zb", opts) -- Scroll down a page keeping cursor at the top
nm("<C-b>", "<C-b>zt", opts) -- Scroll up a page keeping cursor at the bottom
nm("n", "nzzzv", opts) -- Go to next match and center it, unfolding if needed
nm("N", "Nzzzv", opts) -- Go to previous match and center it, unfolding if needed

-- Yank to system clipboard
nm("<leader>y", '"+y', opts)
nm("<leader>Y", '"+Y', opts)

-- Delete without saving to register
nm("<leader>d", '"_d', opts)
nm("<leader>x", '"_x', opts)

nm("<leader>f", "lua vim.lsp.buf.format", opts) -- Format file

-- Center after goto line and go to beginning of line
nm("G", "Gzz0", opts)

nm("<leader>/", "<Plug>NERDCommenterToggle", opts) -- Toggle comment

-- search for word under cursor
nm("<C-/>", "/<C-r><C-w><CR>zz", opts)
nm("<C-?>", "?<C-r><C-w><CR>zz", opts)

-- search and replace word under cursor
nm("<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts)

nm("]q", ":cnext<CR>zz", opts) -- Go to next quickfix item
nm("[q", ":cprev<CR>zz", opts) -- Go to previous quickfix item
--nm("<cr>", "ciw", opts)
--nm("<S-cr>", "ce", opts)
-- Want to c to the next subword (separated by - or _ or camelCase)
--nm("<C-cr>", "cgn", opts)

-- Insert --
-- Press jk or kj fast to exit insert mode
im("jk", "<ESC>", opts)
im("kj", "<ESC>", opts)
-- Press jj or kk fast to exit insert mode (and go down or up 2 lines)
im("jj", "<ESC><Down><Down>", opts)
im("kk", "<ESC><Up><Up>", opts)
-- Press hhh or lll fast to exit insert mode (and go left or right 3 times)
im("hhh", "<ESC><Left><Left><Left>", opts)
im("lll", "<ESC><Right><Right><Right>", opts)

-- Press ww to exit insert mode and go to next word
im("ww", "<ESC>ww", opts)

-- Press zt to exit insert mode move to top of screen, remaining in insert mode
-- Press zb to exit insert mode move to bottom of screen, remaining in insert mode
im("zt", "<ESC>zta", opts)
im("zb", "<ESC>zba", opts)

-- Move line up and down and indent
im("<A-Down>", "<esc>:move .+1<CR>==a", opts)
im("<A-Up>", "<esc>:move .-2<CR>==a", opts)

-- Save without exiting insert mode
im(":w<CR>", "<ESC>:w<CR>a", opts)
-- Generate and write a UUID to the z register
--im("$guid", "<cmd>let @z = system('uuidgen')<CR><cmd>put z<CR>", opts)--

im("<C-h>", "<C-o><C-h>", opts)

-- Visual --
-- Stay in visual mode after indenting
vm("<", "<gv", opts)
vm(">", ">gv", opts)

-- Move text up and down
vm("<A-j>", ":move '>+1<CR>gv=gv", opts)
vm("<A-k>", ":move '<-2<CR>gv=gv", opts)

-- Keep the current register after pasting
vm("p", '"_dP', opts)

-- Yank to system clipboard
vm("<leader>y", '"+y', opts)
vm("<leader>Y", '"+Y', opts)

-- Delete without saving to register
vm("<leader>d", '"_d', opts)
vm("<leader>x", '"_x', opts)

-- Toggle comment
vm("<leader>/", "<Plug>NERDCommenterToggle", opts) -- Toggle comment

vm("[[", "^?^func<CR>zz", opts) -- Go to the start of the previous function or method
vm("]]", "/^func<CR>zz", opts) -- Go to the start of the next function or method
vm("]f", "/^func\\s*\\w<CR>zz", opts) -- Go to the start of the next function
vm("[f", "^?^func\\s*\\w<CR>zz", opts) -- Go to the start of the previous function
vm("[m", "^?^func\\s*(<CR>zz", opts) -- Go to the start of the previous method
vm("]m", "/^func\\s*(<CR>zz", opts) -- Go to the start of the next method

-- Visual Block --
-- Move text up and down
xm("<A-j>", ":move '>+1<CR>gv=gv", opts)
xm("<A-k>", ":move '<-2<CR>gv=gv", opts)

-- Paste, deleting selection, keeping register
xm("p", '"_dP', opts)

-- Yank into system clipboard
xm("<leader>y", '"+y', opts)
xm("<leader>Y", '"+Y', opts)

-- Delete without saving to register
xm("<leader>d", '"_d', opts)
xm("<leader>x", '"_x', opts)

-- Toggle comment
xm("<leader>/", "<Plug>NERDCommenterToggle", opts) -- Toggle comment
-- Terminal --
-- Better terminal navigation
-- tm("<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- tm("<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- tm("<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- tm("<C-l>", "<C-\\><C-N><C-w>l", term_opts)

--vim.keymap.set({ "n", "i", "t" }, "<C-`>", '<cmd>lua require"toggleterm".smart_toggle()<CR>', term_opts)
vim.keymap.set(
	{ "n", "i", "t" },
	"<C-`>",
	'<cmd>exe v:count1 . "ToggleTerm size=10 direction=horizontal"<cr>',
	term_opts
)
vim.keymap.set(
	{ "n", "i", "t" },
	"<C-Right><C-`>",
	'<cmd>exe v:count1 . "ToggleTerm size=50 direction=vertical"<cr>',
	term_opts
)

-- Find a better way to do this; if no number provided and more than one terminal exists then toggle all
vim.keymap.set({ "n", "t" }, "<leader>`", "<cmd>ToggleTermToggleAll<cr>", term_opts)
tm("<esc>", [[<C-\><C-n>]], term_opts)
tm("<C-h>", [[<C-\><C-n><C-w>h]], term_opts)
tm("<C-j>", [[<C-\><C-n><C-w>j]], term_opts)
tm("<C-k>", [[<C-\><C-n><C-w>k]], term_opts)
tm("<C-l>", [[<C-\><C-n><C-w>l]], term_opts)
tm("<C-w>", [[<C-\><C-n><C-w>w]], term_opts)

--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
--vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
--vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- TODO: Unset hlsearch on any keypress other than n/N

-- let &hlsearch = 0

-- Dap
nm("<F5>", "<cmd>lua require'dap'.continue()<CR>", opts)
nm("<F10>", "<cmd>lua require'dap'.step_over()<CR>", opts)
nm("<F11>", "<cmd>lua require'dap'.step_into()<CR>", opts)
nm("<F12>", "<cmd>lua require'dap'.step_out()<CR>", opts)
nm("<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
nm("<leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts)
nm("<leader>dt", "<cmd>lua require('dap-go').debug_test()<CR>", opts)
nm("<leader>dlt", "<cmd>lua require('dap-go').debug_last_test()<CR>", opts)
