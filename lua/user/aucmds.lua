local ag = vim.api.nvim_create_augroup("hlaugroup", {})

-- Remove highlight on Esc, and re-enable on / or ?
vim.api.nvim_set_keymap("n", "<Esc>", [[:if &hlsearch | set nohlsearch | endif<CR>]], { noremap = true, silent = true })
vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = ag,
	pattern = { "/", "\\?" },
	callback = function()
		vim.opt.hlsearch = true
	end,
})

-- Highlight yanked text for a short period of time
vim.api.nvim_create_autocmd("TextYankPost", {
	group = ag,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "Search" })
	end,
})
