local fmt = require("null-ls").builtins.formatting
local diag = require("null-ls").builtins.diagnostics
require("null-ls").setup({
	sources = {
		fmt.stylua,
		fmt.markdownlint,
		fmt.prettierd,
		fmt.eslint_d,
		fmt.black,
		fmt.shfmt,
		fmt.sqlformat,
		fmt.sqlfmt,
		fmt.gofmt,
		fmt.goimports,
		fmt.rustfmt,
		fmt.lua_format,
		diag.golangci_lint,
		diag.actionlint,
		diag.checkmake,
	},
})
