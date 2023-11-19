return {
	config = {
		root_dir = require("lspconfig/util").root_pattern("*.sln", ".git", "main.cs"),
		filetypes = { "cs", "csproj", "razor", "cshtml", "aspnetcorerazor" },
	},
}
