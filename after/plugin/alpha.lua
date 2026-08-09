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
	tag = "detecting...",
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
	make_targets = {
		{ line = "  loading make targets...", target = nil },
	},
	line_actions = {},
	shortcut_actions = {},
}

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

local function context_lines()
	local pr_line = "pr      none"
	if state.pr then
		pr_line = string.format("pr      #%d %s", state.pr.number, state.pr.title)
	end

	local actions = "actions [s] session  [p] pull  [r] refresh  [q] quit"
	if state.pr then
		actions = "actions [s] session  [p] pull  [o] open-pr  [r] refresh  [q] quit"
	end

	return {
		string.format("%s, %s", greeting(), vim.env.USER or "friend"),
		"",
		"cwd     " .. vim.fn.fnamemodify(cwd, ":~"),
		"now     " .. os.date(TIME_FMT),
		"tmux    " .. state.tmux_info,
		"os      " .. state.os_info,
		"branch  " .. state.branch,
		"tag     " .. state.tag,
		"remote  " .. state.pull_status,
		pr_line,
		"",
		actions,
		"open    [g1-0] diff  [f1-0] file  [m1-0] make  [Enter] row",
	}
end

local function render_section(title, rows)
	local lines = { title }
	for _, row in ipairs(rows) do
		table.insert(lines, row.line)
	end
	return lines
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
	for idx, line in ipairs(lines) do
		local row = idx - 1

		if line == "Git" or line == "Make" or line == "Recents" then
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaHeading", row, 0, #line)
		end

		local label, value = line:match("^([a-z]+)%s+(.+)$")
		if label and value and (label == "cwd" or label == "now" or label == "tmux" or label == "os" or label == "branch" or label == "tag" or label == "remote" or label == "pr" or label == "actions" or label == "open") then
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaLabel", row, 0, #label)
			vim.api.nvim_buf_add_highlight(buf, ns, "AlphaValue", row, #label, #line)
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

		local gk = line:match("^%s*%[(g[0-9])%]%s")
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

		local fk = line:match("^%s*%[(f[0-9])%]%s")
		if fk then
			for _, item in ipairs(state.recent_files) do
				if item.shortcut == fk and item.path then
					state.line_actions[idx] = { kind = "recent", path = item.path }
					state.shortcut_actions[fk] = { kind = "recent", path = item.path }
					break
				end
			end
		end

		local mk = line:match("^%s*%[(m[0-9])%]%s")
		if mk then
			for _, item in ipairs(state.make_targets) do
				if item.shortcut == mk and item.target then
					state.line_actions[idx] = { kind = "make", target = item.target }
					state.shortcut_actions[mk] = { kind = "make", target = item.target }
					break
				end
			end
		end
	end
end

local function redraw_alpha()
	dashboard.section.context.val = context_lines()
	dashboard.section.changes.val = render_section("Git", state.git_changes)
	dashboard.section.make.val = render_section("Make", state.make_targets)
	dashboard.section.recent.val = render_section("Recents", state.recent_files)
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
	end
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
		state.make_targets = { { line = "  no makefile", target = nil } }
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
		state.make_targets = { { line = "  no make recipes found", target = nil } }
		redraw_alpha()
		return
	end

	local out = {}
	for i = 1, math.min(#targets, 10) do
		local digit = i == 10 and "0" or tostring(i)
		table.insert(out, {
			shortcut = "m" .. digit,
			target = targets[i],
			line = string.format("  [m%s] %s", digit, targets[i]),
		})
	end

	if #targets > 10 then
		table.insert(out, { line = string.format("  ... and %d more", #targets - 10), target = nil })
	end

	state.make_targets = out
	redraw_alpha()
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
		state.recent_files = { { line = "  no recent files (last 7 days)", path = nil } }
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
		state.tag = "-"
		state.pull_status = "Not a git repository"
		state.pr = nil
		state.git_changes = { { line = "  not a git repository", path = nil } }
		refresh_recent_from_candidates({})
		redraw_alpha()
		return
	end

	run_system_async({ "git", "-C", cwd, "branch", "--show-current" }, function(ok, out)
		local branch_name = ok and out ~= "" and out or "detached"
		state.branch = branch_name
		redraw_alpha()
		update_pull_status(branch_name)
	end)

	run_system_async({ "git", "-C", cwd, "describe", "--tags", "--always" }, function(ok, out)
		state.tag = ok and out ~= "" and out or "-"
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
		for i = 1, math.min(#status_lines, 10) do
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
				if #status_lines > 10 then
					table.insert(rows, { line = string.format("  ... and %d more", #status_lines - 10), path = nil })
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

dashboard.section.header.val = {
	"",
	"N E O V I M   S T A T U S",
	"-------------------------",
}
dashboard.section.buttons.val = {}
dashboard.section.context = { type = "text", val = context_lines(), opts = { position = "left" } }
dashboard.section.changes = { type = "text", val = render_section("Git", state.git_changes), opts = { position = "left" } }
dashboard.section.make = { type = "text", val = render_section("Make", state.make_targets), opts = { position = "left" } }
dashboard.section.recent = { type = "text", val = render_section("Recents", state.recent_files), opts = { position = "left" } }

local plugin_count = type(_G.packer_plugins) == "table" and vim.tbl_count(_G.packer_plugins) or 0
local startup_ms = tonumber(vim.g.startup_time_ms) or 0
dashboard.section.footer.val = string.format("Loaded %d plugins in %.2fms", plugin_count, startup_ms)

dashboard.config.layout = {
	{ type = "padding", val = 1 },
	dashboard.section.header,
	{ type = "padding", val = 1 },
	dashboard.section.context,
	{ type = "padding", val = 1 },
	dashboard.section.changes,
	{ type = "padding", val = 1 },
	dashboard.section.make,
	{ type = "padding", val = 1 },
	dashboard.section.recent,
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
	redraw_alpha()
end)
