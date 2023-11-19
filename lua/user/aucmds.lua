local ag = vim.api.nvim_create_augroup("hlaugroup", {})

vim.keymap.set("n", "<Esc>", function()
	if vim.opt.hlsearch then
		vim.opt.hlsearch = false
	end
end, { noremap = true, silent = true })
vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = ag,
	pattern = { "/", "\\?" },
	callback = function()
		vim.opt.hlsearch = true
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = ag,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "Search" })
	end,
})
