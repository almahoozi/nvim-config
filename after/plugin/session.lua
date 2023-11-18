require("auto-session").setup({
  log_level = "error",
  auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
  auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir()
      or vim.loop.cwd() == vim.loop.os_homedir() .. "/Documents/Source",
})
