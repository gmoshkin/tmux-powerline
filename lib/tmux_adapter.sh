# Get the current path in the segment.

get_old_tmux_cwd() {
	local env_name=$(tmux display -p "TMUXPWD_#D" | tr -d %)
	local env_val=$(tmux show-environment | grep --color=never "$env_name")
	# The version below is still quite new for tmux. Uncomment this in the future :-)
	#local env_val=$(tmux show-environment "$env_name" 2>&1)

	if [[ ! $env_val =~ "unknown variable" ]]; then
		local tmux_pwd=$(echo "$env_val" | sed 's/^.*=//')
		echo "$tmux_pwd"
	fi
}

get_new_tmux_cwd() {
	tmux display-message -p '#{pane_current_path}'
}

get_tmux_cwd() {
	local tmux_version="$(tmux -V | cut -d' ' -f2)"
	local res=$(echo "$tmux_version < 2.1" | bc)
	if [ "$res" -eq 0 ]; then
		get_new_tmux_cwd
	else
		get_old_tmux_cwd
	fi
}
