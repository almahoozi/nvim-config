vim.keymap.set("n", "<leader>pt", function()
	vim.cmd("TodoTelescope")
end, { desc = "List todo comments in Telescope" })

vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })
