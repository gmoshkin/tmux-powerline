CMD=/home/gmoshkin/dotfiles/scripts/gmail-cpp
TMPNAME=gmail_count.txt
run_segment() {
	[ -f "$CMD" ] || { echo 'build me'; return 1; }
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY:-/tmp}/$TMPNAME"
	local force_update=
	[ -f "$tmp_file" ] || { touch "$tmp_file"; force_update=1; }
	last_update=$(stat -c "%Y" ${tmp_file})
	let interval=60*${TMUX_POWERLINE_SEG_MAILCOUNT_GMAIL_INTERVAL:-5}
	if [ "$(( $(date +"%s") - ${last_update} ))" -gt "$interval" ] ||
		[ -n "$force_update" ]; then
		"$CMD" > "$tmp_file"
		force_update=
	fi
	head "$tmp_file"
	return 0
}
