local shell = os.getenv("SHELL"):match(".*/(.*)")

-- mimic bat grid,header style
local bar =
	[[echo -e "\x1b[38;2;148;130;158m────────────────────────────────────────────────────────────────────────────────\x1b[m";]]
local bar_n =
	[[echo -e "\n\x1b[38;2;148;130;158m────────────────────────────────────────────────────────────────────────────────\x1b[m";]]
local dir_name = [[echo -ne "Dir: \x1b[1m\x1b[38m{}\x1b[m";]]
local is_empty_dir = [[test -z "$(eza -A {})" && echo -ne "  <EMPTY>\n" || ]]
local echo_meta =
	[[test -d {} && echo -ne "Dir: \x1b[1m\x1b[38m{}\x1b[m  <METADATA>" || echo -ne "File: \x1b[1m\x1b[38m{}\x1b[m  <METADATA>";]]

-- bat preview
local bat_prev = "bat --color=always --style=grid,header {}'"

-- eza preview
local eza_flags =
	" --git --git-repos --header --long --mounts --no-user --octal-permissions --total-size --color=always --icons {} "
local eza_cmd = "eza --group-directories-first" .. eza_flags .. [[ | sed "s/\x1b\[4m//g; s/\x1b\[24m//g";]]
local eza_tbl = {
	default = "(" .. bar .. dir_name .. is_empty_dir .. bar_n .. eza_cmd .. bar .. ")",
	fish = "begin; " .. bar .. dir_name .. is_empty_dir .. bar_n .. eza_cmd .. bar .. " end",
}
local eza_prev = eza_tbl[shell] or eza_tbl.default

-- ctrl-space metadata preview
local eza_list_dirs = "eza --list-dirs" .. eza_flags .. [[ | sed "s/\x1b\[4m//g; s/\x1b\[24m//g"']]
local eza_bind_prev = "--bind 'ctrl-space:preview:" .. bar .. echo_meta .. bar_n .. eza_list_dirs

-- fzf
local fzf_from = function(job_args)
	local fd_all_tbl = {
		default = [[(fd --type=d {q}; fd --type=f {q})]],
		fish = "begin; fd --type=d {q}; fd --type=f {q}; end",
	}
	local fd_cwd_tbl = {
		default = [[(fd --max-depth=1 --type=d {q}; fd --max-depth=1 --type=f {q})]],
		fish = "begin; fd --max-depth=1 --type=d {q}; fd --max-depth=1 --type=f {q}; end",
	}
	local cmd_tbl = {
		all = fd_all_tbl[shell] or fd_all_tbl.default,
		cwd = fd_cwd_tbl[shell] or fd_cwd_tbl.default,
		dir = "fd --type=dir {q}",
		file = "fd --type=file {q}",
	}
	local fd_cmd = cmd_tbl[job_args]

	local fzf_tbl = {
		"fzf",
		"--no-multi",
		"--no-sort",
		"--reverse",
		"--prompt='fd> '",
		"--preview-window=up,66%",
		"--preview='test -d {} && " .. eza_prev .. " || " .. bat_prev,
		string.format("--bind='start:reload:%s'", fd_cmd),
		string.format("--bind='change:reload:sleep 0.1; %s || true'", fd_cmd),
		"--bind='ctrl-w:change-preview-window(80%|66%)'",
		"--bind='ctrl-\\:change-preview-window(right|up)'",
		eza_bind_prev,
		-- opts_tbl.fzf,
	}

	local extra = function(cmd)
		local logic = {
			default = { cond = "[[ ! $FZF_PROMPT =~ fd ]] &&", op = "||" },
			fish = { cond = 'not string match -q "*fd*" $FZF_PROMPT; and', op = "; or" },
		}
		local lgc = logic[shell] or logic.default
		local extra_bind = "--bind='ctrl-f:transform:%s "
			.. [[echo "rebind(change)+change-prompt(fd> )+clear-query+reload:%s" %s ]]
			.. [[echo "unbind(change)+change-prompt(fzf> )+clear-query"']]
		return string.format(extra_bind, lgc.cond, cmd, lgc.op, cmd)
	end

	table.insert(fzf_tbl, extra(fd_cmd))

	return table.concat(fzf_tbl, " ")
end

local fail = function(s, ...) ya.notify { title = "fdp", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_, job)
	local _permit = ya.hide()
	local args = fzf_from(job.args[1])

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

return { entry = entry }
