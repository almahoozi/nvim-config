---@diagnostic disable-next-line: unused-local
local function on_attach(bufnr) end

return {
	config = {
		settings = {
			texlab = {
				build = {
					executable = "tectonic",
					args = {
						"-X",
						"compile",
						"%f",
						"--synctex",
						"--keep-logs",
						"--keep-intermediates",
					},
					onSave = false,
				},
				forwardSearch = {
					executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
					args = {
						"-r",
						"%l",
						"%p",
						"%f",
					},
				},
			},
		},
	},
	handler = on_attach,
}
