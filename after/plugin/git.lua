-- Git configuration moved to lua/user/plugins.lua for proper loading order with Lazy.nvim
-- Only keeping git keymaps here since they don't require plugin loading

-- Git keymaps
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gc", ":G commit<CR>")
vim.keymap.set("n", "<leader>gp", ":G push<CR>")
vim.keymap.set("n", "<leader>gB", ":G push<CR>")
