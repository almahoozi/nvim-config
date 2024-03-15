local opts = { noremap = true, silent = true }
local function optsWith(args)
	return vim.tbl_extend("force", opts, args)
end

-- Normal --
vim.keymap.set("n", "-", ":Oil<cr>", opts)

-- Window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", opts)
vim.keymap.set("n", "<leader>j", "<C-w>j", opts)
vim.keymap.set("n", "<leader>k", "<C-w>k", opts)
vim.keymap.set("n", "<leader>l", "<C-w>l", opts)
vim.keymap.set("n", "<leader>wv", "<C-w>v", opts)
vim.keymap.set("n", "<leader>ws", "<C-w>s", opts)

-- Window resizing
vim.keymap.set("n", "<A-Up>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<A-Down>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<A-->", ":vertical resize -1<CR>", opts) -- Mappped to something else
vim.keymap.set("n", "<A-=>", ":vertical resize +2<CR>", opts) -- Mappped to something else

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":bn<CR>", opts)
vim.keymap.set("n", "<S-h>", ":bp<CR>", opts)
vim.keymap.set("n", "]q", ":cn<CR>zz", opts)
vim.keymap.set("n", "[q", ":cp<CR>zz", opts)

-- Convenience positioning
vim.keymap.set("n", "0", "^", opts)
vim.keymap.set("n", "^", "0", opts)
vim.keymap.set({ "n", "v" }, "gg", "gg^", opts)
vim.keymap.set({ "n", "v" }, "G", function()
	if vim.v.count == 0 then
		return "G$"
	else
		return "Gzz"
	end
end, optsWith({ expr = true }))

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", opts)
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", opts)
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-f>zb", opts)
vim.keymap.set({ "n", "v" }, "<C-b>", "<C-b>zt", opts)
vim.keymap.set({ "n", "v" }, "n", "nzzzv", opts)
vim.keymap.set({ "n", "v" }, "N", "Nzzzv", opts)
vim.keymap.set({ "n", "v" }, "J", "mzJ`z", opts)

-- Move line up and down and indent
vim.keymap.set("n", "<A-j>", ":move .+1<CR>==", opts)
vim.keymap.set("n", "<A-k>", ":move .-2<CR>==", opts)

-- Black hole register ops
vim.keymap.set("n", "<leader>d", '"_d', opts)
vim.keymap.set("n", "<leader>x", '"_x', opts)

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)

vim.keymap.set("n", "<leader>/", "<Plug>NERDCommenterToggle", opts)

-- Insert --
-- Exit insert mode
vim.keymap.set("i", "jk", "<ESC>", opts)
vim.keymap.set("i", "kj", "<ESC>", opts)
vim.keymap.set("i", "jjj", "<ESC>jjj", opts)
vim.keymap.set("i", "kkk", "<ESC>kkk", opts)
vim.keymap.set("i", "hhh", "<ESC>hhh", opts)
vim.keymap.set("i", "lll", "<ESC>lll", opts)
vim.keymap.set("i", "www", "<ESC>www", opts)
vim.keymap.set("i", "bbb", "<ESC>bbb", opts)

-- Use normal mappings in insert mode
vim.keymap.set("i", "zt", "<C-o>zt", opts)
vim.keymap.set("i", "zb", "<C-o>zb", opts)
vim.keymap.set("i", "<A-j>", "<C-o>:move .+1<CR><C-o>==", opts)
vim.keymap.set("i", "<A-k>", "<C-o>:move .-2<CR><C-o>==", opts)
vim.keymap.set("i", ":w<CR>", "<C-o>:w<CR>", opts)
vim.keymap.set("i", "<C-h>", "<C-o><C-h>", opts)

-- Visual --
-- Stay in visual mode after indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Move text up and down
vim.keymap.set("v", "<A-j>", ":move '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "<A-k>", ":move '<-2<CR>gv=gv", opts)

-- Black hole register ops
vim.keymap.set("v", "p", '"_dP', opts)
vim.keymap.set("v", "P", '"_dP', opts)
vim.keymap.set("v", "<leader>d", '"_d', opts)
vim.keymap.set("v", "<leader>x", '"_x', opts)

vim.keymap.set({ "n", "v" }, "<leader>/", "<Plug>NERDCommenterToggle", opts) -- Toggle comment

-- Terminal --
--vim.keymap.set({ "n", "i", "t" }, "<C-`>", ':lua require"toggleterm".smart_toggle()<CR>', opts)
-- TODO: Find a better way to do this; if no number provided and more than one terminal exists then toggle all
-- TODO: Don't really need this many terminals; one solid one is enough
vim.keymap.set({ "n", "t" }, "<leader>`", ":ToggleTermToggleAll<cr>", opts)
vim.keymap.set({ "n", "i", "t" }, "<C-`>", ':exe v:count1 . "ToggleTerm size=10 direction=horizontal"<cr>', opts)
vim.keymap.set({ "n", "i", "t" }, "<C-Right><C-`>", ':exe v:count1 . "ToggleTerm size=50 direction=vertical"<cr>', opts)

-- Get out of terminal with muscle memory
vim.keymap.set("t", "<C-w><C-h>", "<C-\\><C-n><C-w>h", opts)
vim.keymap.set("t", "<C-w><C-j>", "<C-\\><C-n><C-w>j", opts)
vim.keymap.set("t", "<C-w><C-k>", "<C-\\><C-n><C-w>k", opts)
vim.keymap.set("t", "<C-w><C-l>", "<C-\\><C-n><C-w>l", opts)
vim.keymap.set("t", "<C-w><C-w>", "<C-\\><C-n><C-w>w", opts)
vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", opts)
vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", opts)
vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", opts)
vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", opts)
vim.keymap.set("t", "<C-w>w", "<C-\\><C-n><C-w>w", opts)

-- Exit terminal mode
vim.keymap.set("t", "<esc>", "<C-\\><C-n>", opts)
vim.keymap.set("t", "jk", "<C-\\><C-n>", opts)
vim.keymap.set("t", "kj", "<C-\\><C-n>", opts)
vim.keymap.set("t", "jjj", "<C-\\><C-n>jjj", opts)
vim.keymap.set("t", "kkk", "<C-\\><C-n>kkk", opts)
vim.keymap.set("t", "hhh", "<C-\\><C-n>hhh", opts)
vim.keymap.set("t", "lll", "<C-\\><C-n>lll", opts)
vim.keymap.set("t", "www", "<C-\\><C-n>www", opts)
vim.keymap.set("t", "bbb", "<C-\\><C-n>bbb", opts)
