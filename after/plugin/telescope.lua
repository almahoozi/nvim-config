local builtin = require("telescope.builtin")
local telescope = require("telescope")

telescope.load_extension("media_files")
telescope.load_extension("fzf")
telescope.setup({
	extensions = { media_files = { filetypes = { "png", "jpg", "jpeg", "webp" } } },
	defaults = {
		mappings = {
			i = { ["A-/"] = "to_fuzzy_refine" },
			n = { ["/"] = "to_fuzzy_refine" },
		},
	},
})

-- TODO: Copied the <leader>p* mappings from Prime and now I'm used to them; hate them
vim.keymap.set("n", "<leader>pf", function()
	local ok, _ = pcall(builtin.git_files, {})
	if not ok then
		builtin.find_files({})
	end
end, {})
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>ps", builtin.live_grep, {})
vim.keymap.set("n", "<leader>pr", builtin.resume, {})
vim.keymap.set("n", "<leader>pb", builtin.buffers, {})
vim.keymap.set("n", "<leader>po", builtin.oldfiles, {})

vim.keymap.set("n", "<leader>pm", telescope.extensions.media_files.media_files, {})
vim.keymap.set("n", "<leader>p", builtin.registers, {})

vim.keymap.set("n", "<C-/>", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, {})
