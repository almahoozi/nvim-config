local spectre = require("spectre")
spectre.setup({
	live_update = true,
	is_insert_mode = true,
	mapping = {
		["run_current_replace"] = {
			map = "<leader>r",
			cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
			desc = "replace current line",
		},
	},
})

vim.keymap.set("n", "<leader>s", function()
	spectre.open_visual({
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
	pattern = "uspectre://*",
	callback = function(_)
		vim.bo.wrap = true
	end,
})
