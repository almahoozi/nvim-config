local M = {}

-- Not used in favor of .luarc.json
local function config()
	local runtime_path = vim.split(package.path, ";")
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")
	return {
		settings = {
			Lua = {
				telemetry = { enable = false },
				runtime = {
					version = "LuaJIT",
					path = runtime_path,
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.stdpath("config") .. "/lua",
						vim.fn.stdpath("data") .. "/site/pack/packer",
					},
				},
			},
		},
	}
end

M.config = config()
M.config = {} -- TODO: Remove this line to use the above config
return M
