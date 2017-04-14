# My Theme

if patched_font_in_use; then
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
else
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

__current_status_style=$(tmux show-options -g status-bg)
__current_bg_color=$(expr "$__current_status_style" : '.*bg=\([a-zA-Z0-9]*\)')
if [ "$__current_bg_color" == "black" ]; then
	__current_bg_color_num=0
else
	__current_bg_color_num=${__current_bg_color/#colour/}
fi
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=$__current_bg_color_num
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'7'}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

TMUX_POWERLINE_DEFAULT_TRUNCATION=${TMUX_POWERLINE_DEFAULT_TRUNCATION:-'170'}

# Format: segment_name background_color foreground_color [non_default_separator] [ non_default_truncation ]

if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		"mode_indicator"
		# "session_width 0 15 0"
		"tmux_session_info 10 15 50" \
		"hostname 4 15 50" \
		# "ifstat 30 255" \
		# "ifstat_sys 30 255" \
		"lan_ip 12 15 ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN} 150" \
		"wan_ip 12 15 150" \
		"vcs_branch 4 15 140" \
		"vcs_compare 5 15" \
		"vcs_staged 2 15" \
		"vcs_modified 9 15" \
		"vcs_others 12 0" \
	)
fi

if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#"earthquake 3 0" \
		"mailcount 1 15 90" \
		# "pwd 12 15" \
		# "cpu 240 136" \
		"storage 9 15" \
		"now_playing 13 15" \
		"load 8 15" \
		# "tmux_mem_cpu_load 234 136" \
		"weather 4 15" \
		"battery 1 15 80" \
		# "rainbarf 0 0" \
		"xkb_layout 6 15 80" \
		# "sound_volume 2 15" \
		# "currency 5 15"
		"date_day 10 15 50" \
		"date 10 15 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN} 50" \
		"time 10 15 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN} 50" \
		# "utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
	)
fi
