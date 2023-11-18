require("gitlinker").setup()
require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 300,
		--ignore_whitespace = false,
	},
	--word_diff  = true,
	on_attach = function(bufnr)
		--local gs = require("gitsigns")
		local opts = { noremap = true, silent = true }
		local nm = function(...)
			vim.api.nvim_buf_set_keymap(bufnr, "n", ...)
		end
		nm("]c", '<cmd>lua require"gitsigns".next_hunk()<CR>', opts)
		nm("[c", '<cmd>lua require"gitsigns".prev_hunk()<CR>', opts)
		--nm("<leader>ggb", '<cmd>lua require"gitsigns".blame_line()<CR>', opts)
		--nm("<leader>q", '<cmd>lua require"gitsigns".reset_hunk()<CR>', opts)
		--nm("<leader>Q", '<cmd>lua require"gitsigns".reset_buffer()<CR>', opts)
		nm("<leader>gp", '<cmd>lua require"gitsigns".preview_hunk()<CR>', opts)
		nm("<leader>gb", '<cmd>lua require"gitsigns".blame_line({full=true})<CR>', opts)
	end,
})

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
