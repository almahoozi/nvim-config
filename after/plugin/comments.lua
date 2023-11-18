local colors = require("dracula").colors()
require("better-comment").Setup({
	tags = {
		{
			name = "!",
			fg = "#FF2D00",
			bg = colors.bg,
			bold = false,
		},
		{
			name = "?",
			fg = "#3498DB",
			bg = colors.bg,
			bold = false,
		},
		{
			name = "TODO",
			fg = "#FF8C00",
			bg = colors.bg,
			bold = false,
		},
	},
})
