return {
	config = {
		root_dir = require("lspconfig/util").root_pattern("cargo.toml", "rust-project.json", ".git", "main.rs"),
		filetypes = { "rust" },
	},
}
