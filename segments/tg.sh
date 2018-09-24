INTERVAL_IN_MINUTES=5

run_segment() {
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/tg.txt"
	if [ ! -f "$tmp_file" ]; then
		touch $tmp_file
	fi
	last_update=$(stat -c "%Y" ${tmp_file})
	now=$(date +"%s")
	interval=$[${INTERVAL_IN_MINUTES} * 60]
	if [ "$[${now} - ${last_update}]" -gt "${interval}" -o ! -s $tmp_file ]; then
		timeout 10s ~/dotfiles/scripts/tg.py > $tmp_file || rm $tmp_file
	fi
	tg_count=$(cat $tmp_file)
	if [ "$tg_count" -gt 0 ]; then
		echo ✉ $tg_count
	fi
}
