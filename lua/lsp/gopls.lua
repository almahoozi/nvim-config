local function on_attach(bufnr)
	local opts = { noremap = true, silent = true }
	-- TODO: Use treesitter instead
	-- TODO: Remove search highlight automatically (vim.opt.hlsearch = false) or ideally keep the previous search term somehow
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[[", "^?^func<CR>zz", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]]", "/^func<CR>zz", opts)
end

return {
	config = {
		root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git", "main.go"),
		filetypes = { "go", "gomod" },
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
			},
		},
	},
	handler = on_attach,
}
