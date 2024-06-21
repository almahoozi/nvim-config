vim.keymap.set("n", "]t", function()
	local todo_comments = require("todo-comments")
	todo_comments.jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	local todo_comments = require("todo-comments")
	todo_comments.jump_prev()
end, { desc = "Previous todo comment" })
