--- @since 25.2.7

local shell = os.getenv("SHELL"):match(".*/(.*)")
local fail = function(s, ...) ya.notify { title = "fdp", content = string.format(s, ...), timeout = 5, level = "error" } end

-- shell compatibility
local sh_compat = {
	default = {
		wrap = function(cmd) return "(" .. cmd .. ")" end,
		logic = { cond = "[[ ! $FZF_PROMPT =~ fd ]] &&", op = "||" },
	},
	fish = {
		wrap = function(cmd) return "begin; " .. cmd .. "; end" end,
		logic = { cond = 'not string match -q "*fd*" $FZF_PROMPT; and', op = "; or" },
	},
}
local function shell_helper() return sh_compat[shell] or sh_compat.default end
local sh = shell_helper()

-- mimic bat grid,header style
local bar =
	[[echo -e "\x1b[38;2;148;130;158m────────────────────────────────────────────────────────────────────────────────\x1b[m";]]
local bar_n =
	[[echo -e "\n\x1b[38;2;148;130;158m────────────────────────────────────────────────────────────────────────────────\x1b[m";]]

-- preview
local eza_prev = function(prev, opts)
	local name = {
		default = [[echo -ne "Dir: \x1b[1m\x1b[38m{}\x1b[m";]],
		meta = [[test -d {} && echo -ne "Dir: \x1b[1m\x1b[38m{}\x1b[m"]]
			.. [[ || echo -ne "File: \x1b[1m\x1b[38m{}\x1b[m";]],
	}
	local extra_flags = {
		default = "--oneline " .. opts.eza,
		meta = "--git --git-repos --header --long --mounts --no-user --octal-permissions " .. opts.eza_meta,
	}

	return table.concat({
		bar,
		name[prev],
		[[test -z "$(eza -A {})" && echo -ne "  <EMPTY>\n" ||]],
		bar_n,
		"eza",
		extra_flags[prev],
		"--color=always --group-directories-first --icons {};",
		bar,
	}, " ")
end

-- bind toggle fzf match
local bind_match_tmpl = "--bind='ctrl-s:transform:%s "
	.. [[echo "rebind(change)+change-prompt(fd> )+clear-query+reload:%s" %s ]]
	.. [[echo "unbind(change)+change-prompt(fzf> )+clear-query"']]

-- handle user custom options
local fmt_opts = function(opt)
	if type(opt) == "string" then
		return " " .. opt
	elseif type(opt) == "table" then
		return " " .. table.concat(opt, " ")
	end
	return ""
end

local get_custom_opts = ya.sync(function(self)
	local opts = self.custom_opts or {}

	return {
		fzf = fmt_opts(opts.fzf),
		fd = fmt_opts(opts.fd),
		bat = fmt_opts(opts.bat),
		eza = fmt_opts(opts.eza),
		eza_meta = fmt_opts(opts.eza_meta),
	}
end)

-- fzf
local fzf_from = function(job_args, opts)
	local cmd_tbl = {
		all = sh.wrap("fd --type=d " .. opts.fd .. " {q}; fd --type=f " .. opts.fd .. " {q}"),
		cwd = sh.wrap("fd --max-depth=1 --type=d " .. opts.fd .. " {q}; fd --max-depth=1 --type=f " .. opts.fd .. " {q}"),
		dir = "fd --type=dir " .. opts.fd .. " {q}",
		file = "fd --type=file " .. opts.fd .. " {q}",
	}
	local fd_cmd = cmd_tbl[job_args]
	local bat_prev = "bat --color=always " .. opts.bat .. " {}"
	local default_prev = string.format("test -d {} && %s || %s", sh.wrap(eza_prev("default", opts)), bat_prev)

	local fzf_tbl = {
		"fzf",
		"--no-multi",
		"--no-sort",
		"--reverse",
		"--preview-label='content'",
		"--prompt='fd> '",
		"--preview-window=up,66%",
		string.format("--preview='%s'", default_prev),
		string.format("--bind='start:reload:%s'", fd_cmd),
		string.format("--bind='change:reload:sleep 0.1; %s || true'", fd_cmd),
		"--bind='ctrl-]:change-preview-window(80%|66%)'",
		"--bind='ctrl-\\:change-preview-window(right|up)'",
		string.format("--bind 'alt-c:change-preview-label(content)+change-preview:%s'", default_prev),
		string.format("--bind 'alt-m:change-preview-label(metadata)+change-preview:%s'", eza_prev("meta", opts)),
		string.format(bind_match_tmpl, sh.logic.cond, fd_cmd, sh.logic.op),
		opts.fzf,
	}

	return table.concat(fzf_tbl, " ")
end

local function setup(self, opts)
	opts = opts or {}

	self.custom_opts = {
		fzf = opts.fzf,
		fd = opts.fd,
		bat = opts.bat,
		eza = opts.eza,
		eza_meta = opts.eza_meta,
	}
end

local function entry(_, job)
	local _permit = ya.hide()
	local custom_opts = get_custom_opts()
	local args = fzf_from(job.args[1], custom_opts)

	local child, err =
		Command(shell):args({ "-c", args }):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

	if not child then
		return fail("Command failed with error code %s.", err)
	end

	local output, err = child:wait_with_output()
	if not output then -- unreachable?
		return fail("Cannot read command output, error code %s", err)
	elseif output.status.code == 130 then -- interrupted with CTRL-C or ESC
		return
	elseif output.status.code == 1 then -- no match
		return ya.notify { title = "fdp", content = "No file selected", timeout = 5 }
	elseif output.status.code ~= 0 then -- anything other than normal exit
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")

	if target ~= "" then
		local is_dir = target:sub(-1) == "/"
		ya.manager_emit(is_dir and "cd" or "reveal", { target })
	end
end

return { entry = entry, setup = setup }
