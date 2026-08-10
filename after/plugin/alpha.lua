local ok_alpha, alpha = pcall(require, "alpha")
if not ok_alpha then
	return
end

local ok_dashboard, dashboard = pcall(require, "alpha.themes.dashboard")
if not ok_dashboard then
	return
end

local uv = vim.uv or vim.loop
local ns = vim.api.nvim_create_namespace("alpha_status_dashboard")
local cwd = vim.fn.getcwd()
local TIME_FMT = "%Y-%m-%d %H:%M"

local state = {
	is_git_repo = nil,
	branch = "detecting...",
	version = "detecting...",
	latest_tag = nil,
	latest_tag_date = nil,
	latest_tag_unix = nil,
	pull_status = "checking...",
	pr = nil,
	tmux_info = "checking...",
	os_info = "checking...",
	git_changes = {
		{ line = "  loading git changes...", path = nil },
	},
	recent_files = {
		{ line = "  loading recent files...", path = nil },
	},
	history = {
		{ line = "  loading history...", commit = nil },
	},
	make_targets = {
		{ line = "  loading make targets...", target = nil },
	},
	todo_rows = {
		{ line = "  loading todo comments...", path = nil },
	},
	git_limit = 10,
	make_limit = 10,
	todo_page_size = 10,
	todo_tag_limits = {},
	todo_tag_keys = {},
	todo_key_to_tag = {},
	line_actions = {},
	shortcut_actions = {},
}

local section_is_visible

local function run_system_sync_lines(cmd)
	local result = vim.system(cmd, { text = true }):wait()
	if result.code ~= 0 then
		return {}
	end
	local out = vim.trim(result.stdout or "")
	if out == "" then
		return {}
	end
	return vim.split(out, "\n", { trimempty = true })
end

local function run_system_async(cmd, on_done)
	vim.system(cmd, { text = true }, function(result)
		vim.schedule(function()
			on_done(result.code == 0, vim.trim(result.stdout or ""), vim.trim(result.stderr or ""))
		end)
	end)
end

local function get_alpha_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "alpha" then
			return buf
		end
	end
	return nil
end

local function greeting()
	local hour = tonumber(os.date("%H")) or 0
	if hour < 12 then
		return "Good morning"
	elseif hour < 18 then
		return "Good afternoon"
	end
	return "Good evening"
end

local function title_case_name(value)
	if not value or value == "" then
		return "Friend"
	end
	local sanitized = value:gsub("[._%-]", " ")
	local titled = sanitized:gsub("(%a)([%w']*)", function(first, rest)
		return string.upper(first) .. string.lower(rest)
	end)
	return titled
end

local function has_local_session()
	local candidates = { cwd .. "/Session.vim", cwd .. "/.Session.vim" }
	for _, path in ipairs(candidates) do
		if vim.fn.filereadable(path) == 1 then
			return true
		end
	end
	return false
end

local function format_duration(total_seconds)
	total_seconds = math.max(0, math.floor(total_seconds or 0))
	local days = math.floor(total_seconds / 86400)
	local hours = math.floor((total_seconds % 86400) / 3600)
	local minutes = math.floor((total_seconds % 3600) / 60)

	if days > 0 then
		return string.format("%dd %dh %dm", days, hours, minutes)
	end
	if hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	end
	return string.format("%dm", minutes)
end

local function truncate_text(text, max_len)
	if not text or #text <= max_len then
		return text
	end
	return text:sub(1, max_len - 1) .. "..."
end

local function format_tag_line()
	if not state.latest_tag or state.latest_tag == "" then
		return "-"
	end

	local tag_text = state.latest_tag
	if state.latest_tag_date and state.latest_tag_date ~= "" then
		tag_text = tag_text .. " " .. state.latest_tag_date
	end

	if state.latest_tag_unix then
		local since = format_duration(os.time() - state.latest_tag_unix)
		tag_text = string.format("%s (%s)", tag_text, since)
	end

	return tag_text
end

local function pick_todo_tag_key(tag, used)
	local lowered = string.lower(tag or "")
	for ch in lowered:gmatch("[%w]") do
		if not used[ch] then
			used[ch] = true
			return ch
		end
	end
	for code = string.byte("a"), string.byte("z") do
		local ch = string.char(code)
		if not used[ch] then
			used[ch] = true
			return ch
		end
	end
	for code = string.byte("0"), string.byte("9") do
		local ch = string.char(code)
		if not used[ch] then
			used[ch] = true
			return ch
		end
	end
	return nil
end

local function assign_todo_tag_keys(tags)
	local used = {}
	local next_keys = {}

	for _, tag in ipairs(tags) do
		local key = state.todo_tag_keys[tag]
		if key and not used[key] then
			used[key] = true
			next_keys[tag] = key
		end
	end

	for _, tag in ipairs(tags) do
		if not next_keys[tag] then
			next_keys[tag] = pick_todo_tag_key(tag, used)
		end
	end

	state.todo_tag_keys = next_keys
	state.todo_key_to_tag = {}
	for tag, key in pairs(next_keys) do
		if key then
			state.todo_key_to_tag[key] = tag
		end
	end
end

local function context_lines()
	local action_parts = {}
	if has_local_session() then
		table.insert(action_parts, "[s] session")
	end
	if state.is_git_repo then
		table.insert(action_parts, "[p] pull")
	end
	if state.pr then
		table.insert(action_parts, "[o] open-pr")
	end
	table.insert(action_parts, "[r] refresh")
	table.insert(action_parts, "[q] quit")
	local actions = "actions " .. table.concat(action_parts, "  ")

	local open_parts = {}
	if section_is_visible("Changes", state.git_changes) then
		table.insert(open_parts, "[g1-0] diff")
	end
	if section_is_visible("Recent", state.recent_files) then
		table.insert(open_parts, "[f1-0] file")
	end
	if section_is_visible("Make", state.make_targets) then
		table.insert(open_parts, "[m1-0] make")
	end
	if section_is_visible("Tasks", state.todo_rows) then
		table.insert(open_parts, "[t][type][1-0] task")
	end
	table.insert(open_parts, "[Enter] row")
	local open_line = "open    " .. table.concat(open_parts, "  ")

	local lines = {
		string.format("%s, %s", greeting(), title_case_name(vim.env.USER)),
		"",
		"cwd     " .. vim.fn.fnamemodify(cwd, ":~"),
		"now     " .. os.date(TIME_FMT),
		"tmux    " .. state.tmux_info,
		"os      " .. state.os_info,
	}

	if state.is_git_repo then
		table.insert(lines, "branch  " .. state.branch)
		table.insert(lines, "version " .. state.version)
		table.insert(lines, "tag     " .. format_tag_line())
		table.insert(lines, "remote  " .. state.pull_status)
		if state.pr then
			table.insert(lines, string.format("pr      #%d %s", state.pr.number, state.pr.title))
		end
	end

	table.insert(lines, "")
	table.insert(lines, actions)
	table.insert(lines, open_line)

	return lines
end

local function render_section(title, rows)
	local lines = { title }
	for _, row in ipairs(rows) do
		table.insert(lines, row.line)
	end
	return lines
end

section_is_visible = function(title, rows)
	if title == "Changes" then
		return state.is_git_repo == true and #rows > 0
	end
	return #rows > 0
end

local function build_body_lines()
	local blocks = {}
	if section_is_visible("Changes", state.git_changes) then
		table.insert(blocks, render_section("Changes", state.git_changes))
	end
	if section_is_visible("Recent", state.recent_files) then
		table.insert(blocks, render_section("Recent", state.recent_files))
	end
	if section_is_visible("History", state.history) then
		table.insert(blocks, render_section("History", state.history))
	end
	if section_is_visible("Make", state.make_targets) then
		table.insert(blocks, render_section("Make", state.make_targets))
	end
	if section_is_visible("Tasks", state.todo_rows) then
		table.insert(blocks, render_section("Tasks", state.todo_rows))
	end

	local out = {}
	for i, block in ipairs(blocks) do
		vim.list_extend(out, block)
		if i < #blocks then
			table.insert(out, "")
		end
	end
	return out
end

local function set_palette()
	vim.api.nvim_set_hl(0, "AlphaGitAdded", { fg = "#98c379", bold = true })
	vim.api.nvim_set_hl(0, "AlphaGitModified", { fg = "#e5c07b", bold = true })
	vim.api.nvim_set_hl(0, "AlphaGitDeleted", { fg = "#e06c75", bold = true })
	vim.api.nvim_set_hl(0, "AlphaGitRenamed", { fg = "#56b6c2", bold = true })
	vim.api.nvim_set_hl(0, "AlphaGitUntracked", { fg = "#61afef", bold = true })
	vim.api.nvim_set_hl(0, "AlphaGitConflict", { fg = "#c678dd", bold = true })
	vim.api.nvim_set_hl(0, "AlphaGitIgnored", { fg = "#7f848e", bold = true })
	vim.api.nvim_set_hl(0, "AlphaPlusCount", { fg = "#98c379" })
	vim.api.nvim_set_hl(0, "AlphaMinusCount", { fg = "#e06c75" })
	vim.api.nvim_set_hl(0, "AlphaLink", { fg = "#61afef", underline = true })
	vim.api.nvim_set_hl(0, "AlphaLabel", { fg = "#56b6c2", bold = true })
	vim.api.nvim_set_hl(0, "AlphaValue", { fg = "#c8ccd4" })
	vim.api.nvim_set_hl(0, "AlphaMuted", { fg = "#7f848e" })
	vim.api.nvim_set_hl(0, "AlphaHeading", { fg = "#56b6c2", bold = true })
end

local function apply_highlights(buf)
	state.line_actions = {}
	state.shortcut_actions = {}
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local current_section = nil
	for idx, line in ipairs(lines) do
		local row = idx - 1

		if line == "Changes" or line == "Recent" or line == "History" or line == "Make" or line == "Tasks" then
			current_section = line
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaHeading", row, 0, #line)
		elseif line == "" then
			current_section = nil
		end

		local label, value = line:match("^([a-z]+)%s+(.+)$")
		if label and value and (label == "cwd" or label == "now" or label == "tmux" or label == "os" or label == "branch" or label == "version" or label == "tag" or label == "remote" or label == "pr" or label == "actions" or label == "open") then
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaLabel", row, 0, #label)
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaValue", row, #label, #line)
			if label == "cwd" then
				state.line_actions[idx] = { kind = "cwd" }
			end
		end

		local from = 1
		while true do
			local s, e = line:find("%b[]", from)
			if not s then
				break
			end
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaLink", row, s - 1, e)
			from = e + 1
		end

		local dt_from = 1
		while true do
			local s, e = line:find("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d", dt_from)
			if not s then
				break
			end
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaMuted", row, s - 1, e)
			dt_from = e + 1
		end

		local dur_from = 1
		while true do
			local s, e = line:find("%b()", dur_from)
			if not s then
				break
			end
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaMuted", row, s - 1, e)
			dur_from = e + 1
		end

		if current_section == "Tasks" then
			local todo_loc = line:match("(%S+:%d+)%s*$")
			if todo_loc then
				local s_loc = #line - #todo_loc + 1
				vim.api.nvim_buf_add_highlight(buf, ns, "AlphaMuted", row, s_loc - 1, #line)
			end
		end

		local gk = line:match("^%s*%[(g%d+)%]%s")
		if gk then
			for _, item in ipairs(state.git_changes) do
				if item.shortcut == gk and item.path then
					state.line_actions[idx] = { kind = "git", path = item.path }
					state.shortcut_actions[gk] = { kind = "git", path = item.path }

					local s_status = line:find(" " .. item.status .. " ", 1, true)
					if s_status then
						vim.api.nvim_buf_add_highlight(buf, ns, item.status_hl, row, s_status, s_status + 1)
					end

					local plus = "+" .. tostring(item.adds)
					local minus = "-" .. tostring(item.dels)
					local s_plus = line:find(plus, 1, true)
					local s_minus = line:find(minus, 1, true)
					if s_plus then
						vim.api.nvim_buf_add_highlight(buf, ns, "AlphaPlusCount", row, s_plus - 1, s_plus - 1 + #plus)
					end
					if s_minus then
						vim.api.nvim_buf_add_highlight(buf, ns, "AlphaMinusCount", row, s_minus - 1, s_minus - 1 + #minus)
					end
					break
				end
			end
		end

		local fk = line:match("^%s*%[(f%d+)%]%s")
		if fk then
			for _, item in ipairs(state.recent_files) do
				if item.shortcut == fk and item.path then
					state.line_actions[idx] = { kind = "recent", path = item.path }
					state.shortcut_actions[fk] = { kind = "recent", path = item.path }
					break
				end
			end
		end

		local mk = line:match("^%s*%[(m%d+)%]%s")
		if mk then
			for _, item in ipairs(state.make_targets) do
				if item.shortcut == mk and item.target then
					state.line_actions[idx] = { kind = "make", target = item.target }
					state.shortcut_actions[mk] = { kind = "make", target = item.target }
					break
				end
			end
		end

		local tk = line:match("^%s*%[(t[%w][0-9])%]%s")
		if tk then
			for _, item in ipairs(state.todo_rows) do
				if item.shortcut == tk and item.path and item.lnum then
					state.line_actions[idx] = { kind = "todo", path = item.path, lnum = item.lnum, col = item.col or 1 }
					state.shortcut_actions[tk] = { kind = "todo", path = item.path, lnum = item.lnum, col = item.col or 1 }
					break
				end
			end
		end

		if current_section == "Tasks" and not state.line_actions[idx] then
			for _, item in ipairs(state.todo_rows) do
				if item.path and item.lnum and item.line == line then
					state.line_actions[idx] = { kind = "todo", path = item.path, lnum = item.lnum, col = item.col or 1 }
					break
				end
			end
		end

		if line:match("^%s*%.%.%. and %d+ more") then
			local todo_tag = line:match(" in ([^%s]+)$")
			if todo_tag and todo_tag ~= "" then
				state.line_actions[idx] = { kind = "more", section = "todos", tag = todo_tag }
			elseif current_section == "Changes" then
				state.line_actions[idx] = { kind = "more", section = "changes" }
			elseif current_section == "Make" then
				state.line_actions[idx] = { kind = "more", section = "make" }
			end
		end

		if current_section == "History" and vim.startswith(line, "  ") then
			local commit = line:match("([0-9a-f]+)")
			if commit then
				state.line_actions[idx] = { kind = "history", commit = commit }
			end
		end
	end
end

local function redraw_alpha()
	dashboard.section.context.val = context_lines()
	dashboard.section.body.val = build_body_lines()
	pcall(vim.cmd, "AlphaRedraw")
	vim.defer_fn(function()
		local buf = get_alpha_buf()
		if buf then
			apply_highlights(buf)
		end
	end, 40)
end

local function action_restore_session()
	local candidates = { cwd .. "/Session.vim", cwd .. "/.Session.vim" }
	for _, path in ipairs(candidates) do
		if vim.fn.filereadable(path) == 1 then
			vim.cmd("silent source " .. vim.fn.fnameescape(path))
			vim.notify("Session restored: " .. vim.fn.fnamemodify(path, ":~"), vim.log.levels.INFO)
			return
		end
	end
	vim.notify("No local session file found (Session.vim or .Session.vim)", vim.log.levels.WARN)
end

local function open_git_diff(path)
	if not path or path == "" then
		return
	end
	if vim.fn.exists(":Gedit") == 2 then
		vim.cmd("tabnew")
		vim.cmd("Gedit " .. vim.fn.fnameescape(path))
		vim.cmd("Gvdiffsplit")
		return
	end

	vim.cmd("tabnew")
	local lines = run_system_sync_lines({ "git", "-C", cwd, "diff", "--", path })
	if #lines == 0 then
		lines = run_system_sync_lines({ "git", "-C", cwd, "diff", "--cached", "--", path })
	end
	if #lines == 0 then
		lines = { "No diff for " .. path }
	end
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.bo.filetype = "diff"
	vim.api.nvim_buf_set_name(0, "git-diff://" .. path)
end

local function open_recent_file(path)
	if not path or path == "" then
		return
	end
	vim.cmd("edit " .. vim.fn.fnameescape(cwd .. "/" .. path))
end

local function open_todo_item(path, lnum, col)
	if not path or path == "" then
		return
	end
	vim.cmd("edit " .. vim.fn.fnameescape(path))
	pcall(vim.api.nvim_win_set_cursor, 0, { math.max(1, tonumber(lnum) or 1), math.max(0, (tonumber(col) or 1) - 1) })
end

local function open_history_commit(commit)
	if not commit or commit == "" then
		return
	end

	if vim.fn.exists(":Git") == 2 then
		vim.cmd("tabnew")
		vim.cmd("Git show " .. commit)
		return
	end

	vim.cmd("tabnew")
	local lines = run_system_sync_lines({ "git", "-C", cwd, "show", commit })
	if #lines == 0 then
		lines = { "No details for commit " .. commit }
	end
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.bo.filetype = "git"
	vim.api.nvim_buf_set_name(0, "git-show://" .. commit)
end

local function run_make_target(target)
	if not target or target == "" then
		return
	end
	if vim.fn.executable("make") ~= 1 then
		vim.notify("make is not available", vim.log.levels.ERROR)
		return
	end
	vim.cmd("tabnew")
	vim.fn.termopen({ "make", target }, { cwd = cwd })
	vim.cmd("startinsert")
end

local function invoke_shortcut(prefix)
	local key = vim.fn.getcharstr()
	if key == "" then
		return
	end
	local action = state.shortcut_actions[prefix .. key]
	if not action then
		vim.notify("No entry for " .. prefix .. key, vim.log.levels.INFO)
		return
	end
	if action.kind == "git" then
		open_git_diff(action.path)
	elseif action.kind == "recent" then
		open_recent_file(action.path)
	elseif action.kind == "make" then
		run_make_target(action.target)
	elseif action.kind == "history" then
		open_history_commit(action.commit)
	elseif action.kind == "todo" then
		open_todo_item(action.path, action.lnum, action.col)
	end
end

local function invoke_todo_shortcut()
	local tag_key = string.lower(vim.fn.getcharstr())
	if tag_key == "" then
		return
	end
	local digit = vim.fn.getcharstr()
	if digit == "" then
		return
	end
	local action = state.shortcut_actions["t" .. tag_key .. digit]
	if not action then
		vim.notify("No TODO entry for t" .. tag_key .. digit, vim.log.levels.INFO)
		return
	end
	open_todo_item(action.path, action.lnum, action.col)
end

local function action_open_pr()
	if not state.pr then
		vim.notify("No PR detected for current branch", vim.log.levels.WARN)
		return
	end
	vim.system({ "gh", "pr", "view", "--web" }, { text = true })
end

local function action_pull()
	if state.is_git_repo ~= true then
		vim.notify("Not a git repository", vim.log.levels.WARN)
		return
	end
	vim.notify("Running git pull --ff-only...", vim.log.levels.INFO)
	vim.system({ "git", "-C", cwd, "pull", "--ff-only" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify(vim.trim(result.stdout or "Pull complete"), vim.log.levels.INFO)
			else
				local msg = vim.trim(result.stderr or "git pull failed")
				vim.notify(msg ~= "" and msg or "git pull failed", vim.log.levels.ERROR)
			end
		end)
	end)
end

local function status_char(code)
	if code == "??" then
		return "?", "AlphaGitUntracked"
	end
	if code == "!!" then
		return "!", "AlphaGitIgnored"
	end
	if code:find("U", 1, true) then
		return "U", "AlphaGitConflict"
	end
	if code:find("A", 1, true) then
		return "A", "AlphaGitAdded"
	end
	if code:find("D", 1, true) then
		return "D", "AlphaGitDeleted"
	end
	if code:find("R", 1, true) then
		return "R", "AlphaGitRenamed"
	end
	if code:find("M", 1, true) then
		return "M", "AlphaGitModified"
	end
	return "*", "AlphaGitModified"
end

local function parse_numstat(lines)
	local map = {}
	for _, line in ipairs(lines) do
		local a, d, p = line:match("^(%S+)%s+(%S+)%s+(.+)$")
		if p and a ~= "-" and d ~= "-" then
			map[p] = map[p] or { add = 0, del = 0 }
			map[p].add = map[p].add + (tonumber(a) or 0)
			map[p].del = map[p].del + (tonumber(d) or 0)
		end
	end
	return map
end

local function merge_counts(base, extra)
	for p, v in pairs(extra) do
		base[p] = base[p] or { add = 0, del = 0 }
		base[p].add = base[p].add + v.add
		base[p].del = base[p].del + v.del
	end
end

local function refresh_make_targets()
	local makefiles = { "Makefile", "makefile", "GNUmakefile" }
	local makefile = nil
	for _, name in ipairs(makefiles) do
		local full = cwd .. "/" .. name
		if vim.fn.filereadable(full) == 1 then
			makefile = full
			break
		end
	end

	if not makefile then
		state.make_targets = {}
		redraw_alpha()
		return
	end

	local lines = vim.fn.readfile(makefile)
	local targets = {}
	local seen = {}
	for _, line in ipairs(lines) do
		if not line:match("^%s*#") and line:find(":", 1, true) and not line:match("^%s") and not line:match("^%.") and not line:match("^%w+%s*[:+?]?=") then
			local left = line:match("^([^:]+):")
			if left then
				for target in left:gmatch("[^%s]+") do
					if target ~= "" and not target:find("%%", 1, true) and not seen[target] then
						seen[target] = true
						table.insert(targets, target)
					end
				end
			end
		end
	end

	if #targets == 0 then
		state.make_targets = {}
		redraw_alpha()
		return
	end

	local out = {}
	local limit = math.max(1, state.make_limit or 10)
	for i = 1, math.min(#targets, limit) do
		local digit = i == 10 and "0" or tostring(i)
		table.insert(out, {
			shortcut = "m" .. digit,
			target = targets[i],
			line = string.format("  [m%s] %s", digit, targets[i]),
		})
	end

	if #targets > limit then
		table.insert(out, { line = string.format("  ... and %d more", #targets - limit), target = nil })
	end

	state.make_targets = out
	redraw_alpha()
end

local function refresh_todos_async(retry_count)
	retry_count = retry_count or 0
	local ok_search, search = pcall(require, "todo-comments.search")
	local ok_config, todo_config = pcall(require, "todo-comments.config")
	if ok_search and ok_config and not todo_config.loaded and retry_count < 5 then
		vim.defer_fn(function()
			refresh_todos_async(retry_count + 1)
		end, 120)
		return
	end

	if not ok_search or not ok_config or not todo_config.loaded then
		state.todo_rows = {}
		state.todo_tag_limits = {}
		state.todo_tag_keys = {}
		state.todo_key_to_tag = {}
		redraw_alpha()
		return
	end

	search.search(function(results)
		if not results or vim.tbl_isempty(results) then
			state.todo_rows = {}
			state.todo_tag_limits = {}
			state.todo_tag_keys = {}
			state.todo_key_to_tag = {}
			redraw_alpha()
			return
		end

		local grouped = {}
		for _, item in ipairs(results) do
			local tag = item.tag or "TODO"
			grouped[tag] = grouped[tag] or {}
			table.insert(grouped[tag], item)
		end

		local tags = vim.tbl_keys(grouped)
		table.sort(tags)
		assign_todo_tag_keys(tags)

		local rows = {}
		local valid_limits = {}
		for tag_index, tag in ipairs(tags) do
			local items = grouped[tag]
			local tag_key = state.todo_tag_keys[tag]
			if tag_key then
				local size = math.max(1, state.todo_page_size or 10)
				local limit = state.todo_tag_limits[tag] or size
				if limit < size then
					limit = size
				end
				valid_limits[tag] = limit

				local first = 1
				local last = math.min(#items, limit)
				if #items > size then
					table.insert(rows, { line = string.format("  %s %s (%d-%d/%d)", tag_key, tag, first, last, #items), path = nil })
				else
					table.insert(rows, { line = string.format("  %s %s (%d)", tag_key, tag, #items), path = nil })
				end

				for idx = first, last do
					local item = items[idx]
					local message = truncate_text(item.message or item.text or "", 80)
					local rel = vim.fn.fnamemodify(item.filename or "", ":.")
					if rel == "" then
						rel = item.filename or ""
					end
					local pos = idx
					if pos <= 10 then
						local digit = pos == 10 and "0" or tostring(pos)
						table.insert(rows, {
							shortcut = "t" .. tag_key .. digit,
							path = item.filename,
							lnum = item.lnum,
							col = item.col,
							line = string.format("  [t%s%s] %s %s:%d", tag_key, digit, message, rel, item.lnum or 1),
						})
					else
						table.insert(rows, {
							path = item.filename,
							lnum = item.lnum,
							col = item.col,
							line = string.format("         %s %s:%d", message, rel, item.lnum or 1),
						})
					end
				end

				if last < #items then
					table.insert(rows, { line = string.format("  ... and %d more in %s", #items - last, tag), path = nil })
				end

				if tag_index < #tags then
					table.insert(rows, { line = "", path = nil })
				end
			end
		end
		state.todo_tag_limits = valid_limits

		state.todo_rows = rows
		redraw_alpha()
	end, {
		cwd = cwd,
		disable_not_found_warnings = true,
	})
end

local function refresh_history_async()
	if state.is_git_repo ~= true then
		state.history = {}
		redraw_alpha()
		return
	end

	run_system_async({
		"git",
		"-C",
		cwd,
		"log",
		"--graph",
		"--decorate",
		"--color=never",
		"--pretty=format:%h %d %s | %an",
		"-n",
		"10",
	}, function(ok, out)
		if not ok or out == "" then
			state.history = {}
			redraw_alpha()
			return
		end

		local lines = vim.split(out, "\n", { trimempty = true })
		local rows = {}
		for i = 1, math.min(#lines, 10) do
			local commit = lines[i]:match("([0-9a-f]+)")
			table.insert(rows, { line = "  " .. lines[i], commit = commit })
		end
		state.history = rows
		redraw_alpha()
	end)
end

local function refresh_recent_from_candidates(candidates)
	local cutoff = os.time() - (7 * 86400)
	local entries = {}
	local seen = {}

	for _, file in ipairs(vim.v.oldfiles or {}) do
		if vim.startswith(file, cwd) and vim.fn.filereadable(file) == 1 then
			local rel = vim.fn.fnamemodify(file, ":.")
			if not seen[rel] then
				seen[rel] = true
				table.insert(candidates, rel)
			end
		end
	end

	for _, rel in ipairs(candidates) do
		local full = cwd .. "/" .. rel
		if vim.fn.filereadable(full) == 1 then
			local st = uv.fs_stat(full)
			if st and st.mtime and st.mtime.sec and st.mtime.sec >= cutoff then
				table.insert(entries, { path = rel, mtime = st.mtime.sec })
			end
		end
	end

	table.sort(entries, function(a, b)
		return a.mtime > b.mtime
	end)

	local out = {}
	local uniq = {}
	for _, e in ipairs(entries) do
		if not uniq[e.path] then
			uniq[e.path] = true
			local i = #out + 1
			local digit = i == 10 and "0" or tostring(i)
			table.insert(out, {
				shortcut = "f" .. digit,
				path = e.path,
				line = string.format("  [f%s] %s: %s (%s)", digit, e.path, os.date(TIME_FMT, e.mtime), format_duration(os.time() - e.mtime)),
			})
		end
		if #out >= 10 then
			break
		end
	end

	if #out == 0 then
		state.recent_files = {}
	else
		state.recent_files = out
	end
	redraw_alpha()
end

local function update_pull_status(branch_name)
	state.pull_status = "Checking remote..."
	redraw_alpha()

	run_system_async({ "git", "-C", cwd, "fetch", "--quiet" }, function(ok)
		if not ok then
			state.pull_status = "Fetch failed"
			redraw_alpha()
			return
		end

		run_system_async({ "git", "-C", cwd, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" }, function(ok_upstream, upstream)
			local function compare_with(target)
				run_system_async({ "git", "-C", cwd, "rev-list", "--left-right", "--count", "HEAD..." .. target }, function(ok_cmp, out_cmp)
					if not ok_cmp then
						state.pull_status = "No upstream configured"
						redraw_alpha()
						return
					end
					local ahead_s, behind_s = out_cmp:match("^(%d+)%s+(%d+)$")
					local ahead = tonumber(ahead_s) or 0
					local behind = tonumber(behind_s) or 0
					if behind > 0 then
						state.pull_status = string.format("%d commit(s) to pull from %s", behind, target)
					elseif ahead > 0 then
						state.pull_status = string.format("Up to date (ahead by %d vs %s)", ahead, target)
					else
						state.pull_status = "Up to date"
					end
					redraw_alpha()
				end)
			end

			if ok_upstream and upstream ~= "" then
				compare_with(upstream)
				return
			end

			if branch_name and branch_name ~= "" then
				local origin_branch = "origin/" .. branch_name
				run_system_async({ "git", "-C", cwd, "rev-parse", "--verify", "--quiet", "refs/remotes/" .. origin_branch }, function(ok_origin)
					if ok_origin then
						compare_with(origin_branch)
						return
					end
					run_system_async({ "git", "-C", cwd, "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }, function(ok_head, origin_head)
						if ok_head and origin_head ~= "" then
							compare_with(origin_head)
						else
							state.pull_status = "No upstream configured"
							redraw_alpha()
						end
					end)
				end)
				return
			end

			state.pull_status = "No upstream configured"
			redraw_alpha()
		end)
	end)
end

local function refresh_git_async()
	if state.is_git_repo ~= true then
		state.branch = "-"
		state.version = "-"
		state.latest_tag = nil
		state.latest_tag_date = nil
		state.latest_tag_unix = nil
		state.pull_status = "Not a git repository"
		state.pr = nil
		state.git_changes = {}
		state.history = {}
		refresh_recent_from_candidates({})
		redraw_alpha()
		return
	end

	refresh_history_async()

	run_system_async({ "git", "-C", cwd, "branch", "--show-current" }, function(ok, out)
		local branch_name = ok and out ~= "" and out or "detached"
		state.branch = branch_name
		redraw_alpha()
		update_pull_status(branch_name)
	end)

	run_system_async({ "git", "-C", cwd, "describe", "--tags", "--always" }, function(ok, out)
		state.version = ok and out ~= "" and out or "-"
		redraw_alpha()
	end)

	run_system_async({ "git", "-C", cwd, "for-each-ref", "--sort=-creatordate", "--count=1", "--format=%(refname:short)|%(creatordate:format:%Y-%m-%d %H:%M)|%(creatordate:unix)", "refs/tags" }, function(ok, out)
		if not ok or out == "" then
			state.latest_tag = nil
			state.latest_tag_date = nil
			state.latest_tag_unix = nil
			redraw_alpha()
			return
		end

		local tag, created, created_unix = out:match("^([^|]+)|([^|]+)|(%d+)$")
		state.latest_tag = tag or nil
		state.latest_tag_date = created or nil
		state.latest_tag_unix = tonumber(created_unix)
		redraw_alpha()
	end)

	if vim.fn.executable("gh") == 1 then
		run_system_async({ "gh", "pr", "view", "--json", "number,title,url" }, function(ok, out)
			if ok and out ~= "" then
				local parsed_ok, parsed = pcall(vim.json.decode, out)
				if parsed_ok and type(parsed) == "table" and parsed.number then
					state.pr = { number = parsed.number, title = parsed.title or "", url = parsed.url }
				else
					state.pr = nil
				end
			else
				state.pr = nil
			end
			redraw_alpha()
		end)
	else
		state.pr = nil
	end

	run_system_async({ "git", "-C", cwd, "status", "--short", "--untracked-files=no" }, function(ok, out)
		if not ok or out == "" then
			state.git_changes = { { line = "  working tree clean", path = nil } }
			refresh_recent_from_candidates({})
			redraw_alpha()
			return
		end

		local status_lines = vim.split(out, "\n", { trimempty = true })
		local top = {}
		local candidates = {}
		local limit = math.max(1, state.git_limit or 10)
		for i = 1, math.min(#status_lines, limit) do
			local entry = status_lines[i]
			local code = entry:sub(1, 2)
			local path = vim.trim(entry:sub(4))
			if path:find(" -> ", 1, true) then
				path = vim.split(path, " -> ", { plain = true })[2] or path
			end
			table.insert(top, { code = code, path = path })
			table.insert(candidates, path)
		end
		refresh_recent_from_candidates(candidates)

		run_system_async({ "git", "-C", cwd, "diff", "--numstat" }, function(ok_u, out_u)
			run_system_async({ "git", "-C", cwd, "diff", "--cached", "--numstat" }, function(ok_s, out_s)
				local counts = {}
				if ok_u and out_u ~= "" then
					merge_counts(counts, parse_numstat(vim.split(out_u, "\n", { trimempty = true })))
				end
				if ok_s and out_s ~= "" then
					merge_counts(counts, parse_numstat(vim.split(out_s, "\n", { trimempty = true })))
				end

				local rows = {}
				for i, item in ipairs(top) do
					local status, hl = status_char(item.code)
					local c = counts[item.path] or { add = 0, del = 0 }
					local digit = i == 10 and "0" or tostring(i)
					table.insert(rows, {
						shortcut = "g" .. digit,
						path = item.path,
						status = status,
						status_hl = hl,
						adds = c.add,
						dels = c.del,
						line = string.format("  [g%s] %s +%-4d -%-4d %s", digit, status, c.add, c.del, item.path),
					})
				end
				if #status_lines > limit then
					table.insert(rows, { line = string.format("  ... and %d more", #status_lines - limit), path = nil })
				end
				state.git_changes = rows
				redraw_alpha()
			end)
		end)
	end)
end

local function refresh_header_times()
	local now = os.time()
	local uptime = uv.uptime and uv.uptime() or nil
	if uptime then
		local boot = now - math.floor(uptime)
		state.os_info = string.format("%s (%s)", os.date(TIME_FMT, boot), format_duration(uptime))
	else
		state.os_info = "boot time unavailable"
	end

	if vim.env.TMUX and vim.fn.executable("tmux") == 1 then
		run_system_async({ "tmux", "display-message", "-p", "#{session_created}" }, function(ok, out)
			if ok and out ~= "" then
				local t = tonumber(out)
				if t then
					state.tmux_info = string.format("%s (%s)", os.date(TIME_FMT, t), format_duration(now - t))
				else
					state.tmux_info = "unable to parse start time"
				end
			else
				state.tmux_info = "session time unavailable"
			end
			redraw_alpha()
		end)
	else
		state.tmux_info = "not in tmux"
	end

	redraw_alpha()
end

local function action_change_cwd()
	local next_cwd = vim.fn.input("cwd: ", cwd, "dir")
	if next_cwd == nil or next_cwd == "" then
		return
	end

	local expanded = vim.fn.fnamemodify(next_cwd, ":p")
	if vim.fn.isdirectory(expanded) ~= 1 then
		vim.notify("Invalid directory: " .. next_cwd, vim.log.levels.ERROR)
		return
	end

	if vim.endswith(expanded, "/") then
		cwd = expanded:sub(1, #expanded - 1)
	else
		cwd = expanded
	end

	vim.cmd("cd " .. vim.fn.fnameescape(cwd))
	state.is_git_repo = nil
	state.branch = "detecting..."
	state.version = "detecting..."
	state.latest_tag = nil
	state.latest_tag_date = nil
	state.latest_tag_unix = nil
	state.pull_status = "checking..."
	state.pr = nil
	state.git_changes = { { line = "  loading git changes...", path = nil } }
	state.recent_files = { { line = "  loading recent files...", path = nil } }
	state.history = { { line = "  loading history...", commit = nil } }
	state.make_targets = { { line = "  loading make targets...", target = nil } }
	state.todo_rows = { { line = "  loading todo comments...", path = nil } }
	state.git_limit = 10
	state.make_limit = 10
	state.todo_tag_limits = {}
	state.todo_tag_keys = {}
	state.todo_key_to_tag = {}

	redraw_alpha()
	refresh_header_times()
	refresh_make_targets()
	refresh_todos_async()
	run_system_async({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" }, function(ok, out)
		state.is_git_repo = ok and out == "true"
		refresh_git_async()
	end)
end

local function action_load_more(section, tag)
	if section == "changes" then
		state.git_limit = state.git_limit + 10
		refresh_git_async()
		return
	end

	if section == "make" then
		state.make_limit = state.make_limit + 10
		refresh_make_targets()
		return
	end

	if section == "todos" and tag then
		state.todo_tag_limits[tag] = (state.todo_tag_limits[tag] or state.todo_page_size) + state.todo_page_size
		refresh_todos_async()
	end
end

dashboard.section.header.val = {
	"",
	"N E O V I M",
	"-----------",
}
dashboard.section.buttons.val = {}
dashboard.section.context = { type = "text", val = context_lines(), opts = { position = "left" } }
dashboard.section.body = { type = "text", val = build_body_lines(), opts = { position = "left" } }

local plugin_count = type(_G.packer_plugins) == "table" and vim.tbl_count(_G.packer_plugins) or 0
local startup_ms = tonumber(vim.g.startup_time_ms) or 0
dashboard.section.footer.val = string.format("Loaded %d plugins in %.2fms", plugin_count, startup_ms)

dashboard.config.layout = {
	{ type = "padding", val = 1 },
	dashboard.section.header,
	{ type = "padding", val = 1 },
	dashboard.section.context,
	{ type = "padding", val = 1 },
	dashboard.section.body,
	{ type = "padding", val = 1 },
	dashboard.section.footer,
}

set_palette()
alpha.setup(dashboard.config)

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		set_palette()
		local buf = get_alpha_buf()
		if buf then
			apply_highlights(buf)
		end
	end,
})

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
	pattern = "alpha",
	callback = function(ev)
		vim.keymap.set("n", "s", action_restore_session, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "p", action_pull, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "o", action_open_pr, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "r", function()
			refresh_header_times()
			refresh_git_async()
			refresh_make_targets()
			refresh_todos_async()
		end, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "g", function()
			invoke_shortcut("g")
		end, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "f", function()
			invoke_shortcut("f")
		end, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "m", function()
			invoke_shortcut("m")
		end, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "t", function()
			invoke_todo_shortcut()
		end, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "<CR>", function()
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			local action = state.line_actions[lnum]
			if not action then
				return
			end
			if action.kind == "git" then
				open_git_diff(action.path)
			elseif action.kind == "recent" then
				open_recent_file(action.path)
			elseif action.kind == "make" then
				run_make_target(action.target)
			elseif action.kind == "history" then
				open_history_commit(action.commit)
			elseif action.kind == "cwd" then
				action_change_cwd()
			elseif action.kind == "todo" then
				open_todo_item(action.path, action.lnum, action.col)
			elseif action.kind == "more" then
				action_load_more(action.section, action.tag)
			end
		end, { buffer = ev.buf, silent = true, nowait = true })
		apply_highlights(ev.buf)
	end,
})

vim.schedule(function()
	run_system_async({ "git", "-C", cwd, "rev-parse", "--is-inside-work-tree" }, function(ok, out)
		state.is_git_repo = ok and out == "true"
		refresh_git_async()
	end)
	refresh_header_times()
	refresh_make_targets()
	refresh_todos_async()
	redraw_alpha()
end)
