require("oil").setup({
    columns = {
        "icon", "size", "permissions"
        -- "mtime",
    },
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = true,
    view_options = {show_hidden = true},
    -- delete_to_trash = true,
    keymaps = {
        ["<esc><esc>"] = "actions.close",
        ["q"] = "actions.close",
        ["<Space>"] = "actions.preview"
    }
})
