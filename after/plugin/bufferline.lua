require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		right_mouse_command = nil,
		hover = {
			enabled = true,
			delay = 150,
			reveal = { "close" },
		},
		diagnostics_indicator = function(count, level, _, _)
			local icon = level == "error" and " " or ""
			return "(" .. icon .. " " .. count .. ")"
		end,
	},
})
