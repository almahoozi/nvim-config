local builtin = require("telescope.builtin")
local telescope = require("telescope")

telescope.load_extension("media_files")
telescope.load_extension("fzf")
--telescope.load_extension("lazygit")
telescope.setup({
	extensions = {
		media_files = {
			filetypes = { "png", "jpg", "jpeg", "webp" },
		},
	},
})

vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", builtin.live_grep, {})

vim.keymap.set("n", "<leader>pm", telescope.extensions.media_files.media_files, {})

vim.keymap.set("n", "<leader>pr", "<cmd>Telescope resume<cr>", {})
vim.keymap.set("n", "<leader>pb", builtin.buffers, {})
vim.keymap.set("n", "<leader>po", builtin.oldfiles, {})
vim.keymap.set("n", "<leader>pd", builtin.diagnostics, {})

vim.keymap.set("n", "gr", builtin.lsp_references, {})
