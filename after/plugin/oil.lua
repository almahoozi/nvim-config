require("oil").setup({
	columns = {
		"icon",
		--"permissions",
		"size",
		--"mtime",
	},
	skip_confirm_for_simple_edits = true,
	prompt_save_on_select_new_entry = true,
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["<Esc>"] = "actions.close",
	},
})
