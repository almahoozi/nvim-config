vim.filetype.add({extension = {templ = "templ"}})
vim.api.nvim_create_user_command("Templ", ":!templ generate", {
    complete = "customlist,templ#complete",
    nargs = "?"
})

local function on_attach(bufnr)
    vim.api.nvim_create_autocmd({"BufWritePost"},
                                {command = "!templ generate", buffer = bufnr})
end

return {config = {}, handler = on_attach}
