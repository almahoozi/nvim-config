require("gitlinker").setup()
require("gitsigns").setup({
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 300
        -- ignore_whitespace = false,
    },
    -- word_diff  = true,
    on_attach = function(bufnr)
        -- local gs = require("gitsigns")
        local opts = {noremap = true, silent = true}
        local nm = function(...)
            vim.api.nvim_buf_set_keymap(bufnr, "n", ...)
        end
        nm("]c", ':lua require"gitsigns".next_hunk()<CR>', opts)
        nm("[c", ':lua require"gitsigns".prev_hunk()<CR>', opts)
        -- nm("<leader>ggb", ':lua require"gitsigns".blame_line()<CR>', opts)
        -- nm("<leader>q", ':lua require"gitsigns".reset_hunk()<CR>', opts)
        -- nm("<leader>Q", ':lua require"gitsigns".reset_buffer()<CR>', opts)
        nm("<leader>gp", ':lua require"gitsigns".preview_hunk()<CR>', opts)
        nm("<leader>gb", ':lua require"gitsigns".blame_line({full=true})<CR>',
           opts)
    end
})

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gc", ":G commit<CR>")
vim.keymap.set("n", "<leader>gp", ":G push<CR>")
vim.keymap.set("n", "<leader>gB", ":G push<CR>")
