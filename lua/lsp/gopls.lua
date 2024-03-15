local function on_attach(bufnr)
	local opts = { noremap = true, silent = true }
	-- TODO: Use treesitter instead
	-- TODO: Remove search highlight automatically (vim.opt.hlsearch = false) or ideally keep the previous search term somehow
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[[", "^?^func<CR>zz", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]]", "/^func<CR>zz", opts)
end

return {
	config = {
		cmd = { "gopls", "serve", "-rpc.trace", "-logfile", "/tmp/gopls.log" },
		root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git", "main.go"),
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
				gofumpt = true,
			},
		},
	},
	handler = on_attach,
}
