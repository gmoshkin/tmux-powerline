# Print the current date.

TMUX_POWERLINE_SEG_DATE_FORMAT_DEFAULT="%F"
TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP_DEFAULT="%d/%m"
TMUX_POWERLINE_SEG_DATE_TRESHOLD_DEFAULT="80"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# date(1) format for the date. If you don't, for some reason, like ISO 8601 format you might want to have "%D" or "%m/%d/%Y".
export TMUX_POWERLINE_SEG_DATE_FORMAT="${TMUX_POWERLINE_SEG_DATE_FORMAT_DEFAULT}"
# format to use when the session_width is less than the treshold
export TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP="${TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP_DEFAULT}"
# the treshold
export TMUX_POWERLINE_SEG_DATE_TRESHOLD="${TMUX_POWERLINE_SEG_DATE_TRESHOLD_DEFAULT}"
EORC
	echo "$rccontents"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_DATE_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_DATE_FORMAT="${TMUX_POWERLINE_SEG_DATE_FORMAT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP" ]; then
		export TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP="${TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_DATE_TRESHOLD" ]; then
		export TMUX_POWERLINE_SEG_DATE_TRESHOLD="${TMUX_POWERLINE_SEG_DATE_TRESHOLD_DEFAULT}"
	fi
}

run_segment() {
		__process_settings
	if [ "$TMUX_POWERLINE_SESSION_WIDTH" -gt "$TMUX_POWERLINE_SEG_DATE_TRESHOLD" ]; then
		date +"$TMUX_POWERLINE_SEG_DATE_FORMAT"
	else
		date +"$TMUX_POWERLINE_SEG_DATE_FORMAT_BACKUP"
	fi
	return 0
}
