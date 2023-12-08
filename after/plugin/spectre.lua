local spectre = require("spectre")
spectre.setup({
	live_update = true,
	is_insert_mode = true,
})

vim.keymap.set("n", "<leader>s", function()
	spectre.open_file_search({
		select_word = true,
	})
end)

vim.keymap.set("v", "<leader>s", function()
	spectre.open_visual({
		select_word = true,
	})
end)

local ag = vim.api.nvim_create_augroup("spectre-augroup", {})
vim.api.nvim_create_autocmd("BufEnter", {
	group = ag,
	pattern = "spectre://*",
	callback = function(ev)
		print(vim.inspect(ev))
		vim.bo.wrap = true
	end,
})
