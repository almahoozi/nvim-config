-- Errors when typing in Arabic to give an indication that the language is set incorrectly
-- In the past I've accidentally been in Arabic and wondering why I can't navigate

local ar = {
	"ش",
	"ز",
	"ذ",
	"ي",
	"ث",
	"ب",
	"ل",
	"ا",
	"ه",
	"ت",
	"ن",
	"م",
	"و",
	"ر",
	"خ",
	"ح",
	"ض",
	"ق",
	"س",
	"ف",
	"ع",
	"د",
	"ص",
	"ط",
	"غ",
	"ظ",
	"أ",
	"ئ",
	"ى",
	"آ",
	"ؤ",
	"إ",
}

for _, v in pairs(ar) do
	vim.api.nvim_set_keymap("n", v, ":lua error('Arabic is not supported')<CR>", {})
end
