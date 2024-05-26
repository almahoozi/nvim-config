local function run(args)
	vim.cmd("!go run " .. (args or "."))
end

local tidy = function()
	vim.cmd("!go mod tidy")
end

local function init(args)
	vim.cmd("!go mod init " .. (args or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")))
	vim.cmd("!go mod tidy")
end

vim.api.nvim_create_user_command("Gorun", function(args)
	run(args.args)
end, { nargs = "*" })
vim.api.nvim_create_user_command("Gotidy", tidy, { nargs = 0 })
vim.api.nvim_create_user_command("Goinit", function(args)
	init(args.args)
end, { nargs = "?" })
vim.api.nvim_create_user_command("Go", function(args)
	-- If args = "run" or "tidy" or "init" then run that shortcut
	if args.args == "run" then
		run()
	elseif args.args == "tidy" then
		tidy()
	elseif args.args == "init" then
		init()
	elseif string.sub(args.args, 1, 5) == "init " then
		init(string.sub(args.args, 6))
	else
		vim.cmd("!go " .. args.args)
	end
end, { nargs = "+" })

vim.api.nvim_create_user_command("PR", function()
	vim.cmd("!gh pr create -w")
end, { nargs = 0 })
