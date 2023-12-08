require("dap-go").setup()

local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config]"] = dapui.close

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>", opts)
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>", opts)
vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>", opts)
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>", opts)
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", opts)
vim.keymap.set(
	"n",
	"<leader>B",
	":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
	opts
)
vim.keymap.set("n", "<leader>dt", ":lua require('dap-go').debug_test()<CR>", opts)
vim.keymap.set("n", "<leader>dlt", ":lua require('dap-go').debug_last_test()<CR>", opts)
