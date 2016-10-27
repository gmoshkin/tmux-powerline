# Prints the name of the current day.

run_segment() {
    if [ $TMUX_POWERLINE_SESSION_WIDTH -le 80 ]; then
        date +"%u"
    else
        date +"%a"
    fi
	return 0
}
