TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE_DEFAULT="digital"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Can be either of {"digital", "graphical"}
export TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE="${TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE_DEFAULT}"

EORC
	echo "$rccontents"
}
ICONS=(
	' ∅ '
	'⡀  '
	'⣠  '
	'⣠⡄ '
	'⣠⣴ '
	'⣠⣴⡆'
	'⣠⣴⣾'
)

run_segment() {
	__process_settings
	stats=$(amixer get Master | grep '%' | cut -d '[' -f 2-)
	volume=$(echo ${stats} | sed -e 's/%.*//')
	on_off=$(echo ${stats} | cut -d '[' -f 3 | sed -e 's/\]//')
	case ${TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE} in
		"digital")
			echo ${volume}%
			;;
		"graphical")
			if [ ${on_off} = "on" ]; then
				icon=${ICONS[$(( ${volume} * 6 / 100 ))]}
				echo ${icon}
			else
				echo ${ICONS[0]}
			fi
			;;
		"*")
			echo "Unknown mode"
			;;
	esac
}

__process_settings() {
	if [ -z "${TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE}" ]; then
		export TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE="${TMUX_POWERLINE_SEG_SOUND_VOLUME_MODE_DEFAULT}"
	fi
}
