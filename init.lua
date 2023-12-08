local start_time = vim.loop.hrtime()
require("user")
local end_time = vim.loop.hrtime()
local time = end_time - start_time
local time_ms = time / 1000000
print(string.format("Loaded in %.3fms", time_ms))
