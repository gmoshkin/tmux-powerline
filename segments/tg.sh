run_segment() {
	tg_count=$(~/dotfiles/scripts/tg.py)
	[ "$tg_count" -gt 0 ] && echo ✉ $tg_count
}
