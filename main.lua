local shell = os.getenv("SHELL"):match(".*/(.*)")

local bar =
	[[echo -e "\x1b[38;2;148;130;158m────────────────────────────────────────────────────────────────────────────────\x1b[m";]]
local bar_n =
	[[echo -e "\n\x1b[38;2;148;130;158m────────────────────────────────────────────────────────────────────────────────\x1b[m";]]
local dir_name = [[echo -ne "Dir: \x1b[1m\x1b[38m{}\x1b[m";]]
local bat_prev = "bat --color=always --style=snip,grid,header {}'"
local is_empty_dir = [[test -z "$(eza -A {})" && echo -ne "  <EMPTY>\n" || ]]
local long_flags = "--git --git-repos --header --long --mounts --no-user --octal-permissions --total-size"
local eza_cmd = "eza " .. long_flags .. " --color=always --group-directories-first --icons {};"
local eza_tbl = {
	fish = "begin; " .. bar .. dir_name .. is_empty_dir .. bar_n .. eza_cmd .. bar .. " end",
}
local fzf_cmd = "fzf --reverse --no-multi --preview-window=up,60%"
local preview = " --preview='test -d {} && " .. eza_tbl[shell] .. " || " .. bat_prev
local fd_all_tbl = {
	default = "(fd --type=d; fd --type=f)",
	fish = "begin; echo ../; echo .; fd --type d; fd --type f; end",
}
local fd_all = fd_all_tbl[shell] or fd_all_tbl.default
local fd_cmd_from = {
	all = fd_all,
	cwd = "fd --max-depth=1",
	dir = "fd --type=d",
	file = "fd --type=f",
}

local fail = function(s, ...) ya.notify { title = "fdp", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_, job)
	local _permit = ya.hide()
	local fd_cmd = fd_cmd_from[job.args[1]]
	local args = fd_cmd .. " | " .. fzf_cmd .. preview

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
