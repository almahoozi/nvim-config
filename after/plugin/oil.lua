require("oil").setup({
	columns = {
		"icon",
		"size",
		"permissions",
		-- "mtime",
	},
	skip_confirm_for_simple_edits = true,
	prompt_save_on_select_new_entry = true,
	view_options = { show_hidden = true },
	-- delete_to_trash = true,
	keymaps = {
		["<esc><esc>"] = "actions.close",
		["q"] = "actions.close",
		["<Space>"] = "actions.preview",
	},
	constrain_cursor = "name",
})

-- TODO: autocommand on OilActionPost to set the line to 2 when entering a directory
--         { pattern = "OilActionsPost", modeline = false, data = { err = err, actions = actions } }
--         loop through actions
--         action.type = "select" is the one we want
