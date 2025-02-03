local shell = os.getenv("SHELL"):match(".*/(.*)")

local bar =
	[[\x1b[2m────────────────────────────────────────────────────────────────────────────────\x1b[m\n]]
local bat_prev = "bat --color=always --style=snip,grid,header"
local long_flag = " --git --git-repos --header --long --mounts --no-user --octal-permissions --total-size"
local eza_cmd = "eza --color=always --group-directories-first --icons" .. long_flag
local eza_prev = {
	fish = "begin; " .. [[echo -e "]] .. bar .. [[Dir: \x1b[1m\x1b[38m{}\x1b[m\n]] .. bar .. [["; ]] .. eza_cmd,
}
local fzf_cmd = "fzf --reverse --no-multi --preview-window=up,60%"
local preview = " --preview='test -d {} && "
	.. eza_prev[shell]
	.. " {}; "
	.. [[echo -e "]]
	.. bar
	.. [[";]]
	.. " end"
	.. " || "
	.. bat_prev
	.. " {}'"
local fd_table = {
	default = "(fd --type d; fd --type f)",
	fish = "begin; echo ../; echo .; fd --type d; fd --type f; end",
}
local fd_cmd = fd_table[shell] or fd_table.default
local cmd_args = fd_cmd .. " | " .. fzf_cmd .. preview

local fail = function(s, ...) ya.notify { title = "fdp", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_)
	local _permit = ya.hide()

	local child, err =
		Command(shell):args({ "-c", cmd_args }):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(Command.INHERIT):spawn()

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
