require("user.custom.autosave")
local repl = require("user.custom.repl")
local repler = repl:setup({
	language = "go",
	debug = true,
})
repler.Lang = "go"
