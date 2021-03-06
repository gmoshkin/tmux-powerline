# Print current playing song in your music player of choice.

source "${TMUX_POWERLINE_DIR_LIB}/text_roll.sh"

TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN_DEFAULT="40"
TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD_DEFAULT="trim"
TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT="2"
TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST_DEFAULT="localhost"
TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT_DEFAULT="6600"
TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD_DEFAULT="30"
TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT_DEFAULT="%artist% - %title%"
TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT_DEFAULT="%aa - %tt"
TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR_DEFAULT="♫"
TMUX_POWERLINE_SEG_NOW_PLAYING_CMUS_TIMEOUT_DEFAULT="0.1s"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# Music player to use. Can be any of {audacious, banshee, cmus, itunes, lastfm, mocp, mpd, mpd_simple, pithos, rdio, rhythmbox, spotify, spotify_wine, file}.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER=""
# File to be read in case the song is being read from a file
export TMUX_POWERLINE_SEG_NOW_PLAYING_FILE_NAME=""
# Maximum output length.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN="${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN_DEFAULT}"
# How to handle too long strings. Can be {trim, roll}.
export TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD_DEFAULT}"
# Charcters per second to roll if rolling trim method is used.
export TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED="${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT}"

# Hostname for MPD server in the format "[password@]host"
export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST_DEFAULT}"
# Port the MPD server is running on.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT_DEFAULT}"
# Song display format for mpd_simple. See mpc(1) for delimiters.
export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT_DEFAULT}"
# Song display format for rhythmbox. see "FORMATS" in rhythmbox-client(1).
export TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT_DEFAULT}"

# Username for Last.fm if that music player is used.
export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_USERNAME=""
# How often in seconds to update the data from last.fm.
export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD_DEFAULT}"
# Fancy char to display before now playing track
export TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR="${TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR_DEFAULT}"

# Timeout for cmus-remote
export TMUX_POWERLINE_SEG_NOW_PLAYING_CMUS_TIMEOUT="${TMUX_POWERLINE_SEG_NOW_PLAYING_CMUS_TIMEOUT_DEFAULT}"
EORC
	echo "$rccontents"
}

__log() {
	echo "$@" > "${TMUX_POWERLINE_DIR_TEMPORARY}/now_playing.txt"
}

run_segment() {
	__process_settings

	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER" ]; then
		return 1
	fi

	local np
	local app_exit
	IFS=',' read -ra PLAYERS <<< "$TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER"
	for i in "${PLAYERS[@]}"; do
		case "$i" in
			"audacious")  np=$(__np_audacious) ;;
			"banshee")  np=$(__np_banshee) ;;
			"cmus")  np=$(__np_cmus) ;;
			"itunes")  np=$(__np_itunes) ;;
			"lastfm")  np=$(__np_lastfm) ;;
			"mocp")  np=$(__np_mocp) ;;
			"mpd")  np=$(__np_mpd) ;;
			"mpd_simple")  np=$(__np_mpd_simple) ;;
			"pithos") np=$(__np_pithos) ;;
			"rdio")  np=$(__np_rdio) ;;
			"rhythmbox")  np=$(__np_rhythmbox) ;;
			"spotify")  np=$(__np_spotify) ;;
			"file")  np=$(__np_file) ;;
			"spotify_wine")  np=$(__np_spotify_native) ;;
			*)
				echo "Unknown music player type [${TMUX_POWERLINE_SEG_NOW_PLAYING_MUSIC_PLAYER}]";
				return 1
		esac
		app_exit="$?"
		[ -n "$np" ] && break
	done

	local exitcode="$app_exit"
	if [ "${exitcode}" -ne 0 ]; then
		return ${exitcode}
	fi
	if [ -n "$np" ]; then
		case "$TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD" in
			"roll")
				np=$(roll_text "${np}" ${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN} ${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT})
				;;
			"trim")
				np=${np:0:TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN}
				;;
		esac
		echo "${TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR} ${np}"
	fi
	return 0
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN="${TMUX_POWERLINE_SEG_NOW_PLAYING_MAX_LEN_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_TRIM_METHOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED="${TMUX_POWERLINE_SEG_NOW_PLAYING_ROLL_SPEED_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR="${TMUX_POWERLINE_SEG_NOW_PLAYING_NOTE_CHAR_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT" ]; then
		export TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT="${TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT}"
	fi;
}

__np_mpd() {
	cd "$TMUX_POWERLINE_DIR_SEGMENTS"

	if [ ! -x "np_mpd" ]; then
		make clean np_mpd &>/dev/null
	fi

	if [ ! -x "np_mpd" ]; then
		return 2
	fi

	np=$(MPD_HOST="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST" MPD_PORT="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT" ./np_mpd)
	echo "$np"
}

__np_file() {

	np=$(cat $TMUX_POWERLINE_SEG_NOW_PLAYING_FILE_NAME | tr '\n' '|')
	echo "$np"
}


__np_mpd_simple() {
	np=$(MPD_HOST="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_HOST" MPD_PORT="$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_PORT" mpc current -f "$TMUX_POWERLINE_SEG_NOW_PLAYING_MPD_SIMPLE_FORMAT" 2>&1)
	if [ $? -eq 0 ] && [ -n "$np" ]; then
		mpc | grep "paused" > /dev/null
		if [ $? -eq 0 ]; then
			return 1
		fi
		echo "$np"
	fi
}


__np_audacious() {
	audacious_pid=$(pidof audacious)
	if [ -n "$audacious_pid" ]; then
		if $(audtool playback-playing); then
			np=$(audtool current-song)
			echo "$np"
		fi
	fi
}

__np_banshee() {
	banshee_pid=$(pidof banshee)
	if [ -n "$banshee_pid" ]; then
		banshee_status=$(banshee --query-current-state 2> /dev/null)
		if [[ "$banshee_status" == "current-state: playing" ]]; then
			np=$(banshee --query-artist --query-title | cut  -d ":" -f2 | sed  -e 's/ *$//g' -e 's/^ *//g'| sed -e ':a;N;$!ba;s/\n/ - /g' )
			echo "$np"
		fi
	fi
}

__np_parse_cmus_output() {
	awk -e '
		$2 == "artist" {
			artist = "";
			for ( i = 3; i <=NF; i++ )
				artist = artist $i " ";
		}
		$2 == "title" {
			title = "";
			for ( i = 3; i <=NF; i++ )
				title = title $i " ";
		}
		$1 == "status" {
			status = $2
		}
		END {
			print status "@" artist "- " title
		}
	'
}

__cmus-remote() {
	local cmus_addr=${CMUS_ADDR:-${XDG_RUNTIME_DIR}/cmus-socket}
	timeout $TMUX_POWERLINE_SEG_NOW_PLAYING_CMUS_TIMEOUT cmus-remote --server "$cmus_addr" --passwd "${CMUS_PWD}" $@
}
__np_cmus_now_playing() {
	__cmus-remote -Q | __np_parse_cmus_output
}

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	head -1 "${tmp_file}"
	exit
}

__np_cmus_remote() {
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/cmus_remote.txt"
	local period="$TMUX_POWERLINE_SEG_NOW_PLAYING_CMUS_REMOTE_UPDATE_PERIOD"
	if [ -z "$period" -o "$period" -eq 0 ]; then
		exit
	fi
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			local last_update=$(stat -f "%m" ${tmp_file})
		elif shell_is_linux; then
			local last_update=$(stat -c "%Y" ${tmp_file})
		fi
		local time_now=$(date +%s)

		local up_to_date=$(echo "(${time_now}-${last_update}) < ${period}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	local host="$TMUX_POWERLINE_SEG_NOW_PLAYING_CMUS_REMOTE_HOST"
	if [ -z "$host" ]; then
		exit
	fi

	#FIXME
	local res=$(echo "cmus-remote --server $host --passwd \"${CMUS_PWD}\" -Q" | __np_parse_cmus_output)
	echo $res > "$tmp_file"
	echo $(date) >> "$tmp_file"
	echo $res
}

__np_cmus_settings() {
	tmp=$(__cmus-remote -C "set follow?")
	if [[ "$tmp" == *true* ]]; then
		follow="F"
	else
		follow=" "
	fi
	__cmus-remote -Q |
		awk -e '
			$2 == "repeat_current" {
				rep_cur = ($3 == "true");
			}
			$2 == "play_library" {
				lib = ($3 == "true");
			}
			$2 == "play_sorted" {
				sort = ($3 == "true") ? ("sorted ") : ("");
			}
			$2 == "aaa_mode" {
				aaa = $3;
			}
			$2 == "continue" {
				cont = ($3 == "true") ? ("C") : (" ");
			}
			$2 == "repeat" {
				rep = ($3 == "true") ? ("R") : (" ");
			}
			$2 == "shuffle" {
				shuf = ($3 == "true") ? ("S") : (" ");
			}
			$1 == "status" {
				status = $2
			}
			END {
				if ( rep_cur ) {
					left = "repeat current"
				} else if ( lib ) {
					left = aaa " " sort "lib"
				} else {
					left = "playlist"
				}
				right = cont "'"$follow"'" rep shuf
				print status "@" left "|", right " "
			}
		' 2> "$TMUX_POWERLINE_DIR_TEMPORARY/cmus_debug.txt"
}

__np_cmus() {
	mode=$(cat "$TMUX_POWERLINE_DIR_TEMPORARY"/cmus_mode.txt 2>/dev/null)
	case "$mode" in
		now_playing )
			res=$(__np_cmus_now_playing)
			;;
		settings )
			res=$(__np_cmus_settings)
			;;
		* )
			res=$(__np_cmus_now_playing)
			;;
	esac
	np_with_a_space_on_the_end=${res/#*@/}
	np=${np_with_a_space_on_the_end:0:-1}
	status=${res/%@*/}
	if [[ "$status" == *playing* ]]; then
		echo "$np"
	else
		__log "'$status@$np'"
	fi
}

__np_itunes() {
	[ ! shell_is_osx ] && return 1
	np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_itunes.script)
	echo "$np"
}

__np_lastfm() {
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/np_lastfm.txt"
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" ${tmp_file})
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" ${tmp_file})
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			np=$(cat ${tmp_file})
		fi
	fi

	if [ -z "$np" ]; then
		np=$(curl --max-time 2 -s  http://ws.audioscrobbler.com/1.0/user/${TMUX_POWERLINE_SEG_NOW_PLAYING_LASTFM_USERNAME}/recenttracks.txt | head -n 1 | sed -e 's/^[0-9]*,//' | sed 's/\xe2\x80\x93/-/')
		if [ "$?" -eq "0" ] && [ -n "$np" ]; then
			echo "${np}" > $tmp_file
		fi
	fi
	echo "$np"
}

__np_pithos() {
	if [ "$(dbus-send --reply-timeout=10 --print-reply --dest=net.kevinmehall.Pithos /net/kevinmehall/Pithos net.kevinmehall.Pithos.IsPlaying 2>/dev/null | grep boolean | cut -d' ' -f5)" == "true" ]; then
		np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_pithos.py)
		echo "$np"
	fi
}

__np_mocp() {
	mocp_pid=$(pidof mocp)
	if [ -n "$mocp_pid" ]; then
		np=$(mocp -i | grep ^Title | sed "s/^Title://")
		mocp_paused=$(mocp -i | grep ^State | sed "s/^State: //")
		if [ -n "$np" -a "$mocp_paused" != "PAUSE" ]; then
			echo "$np"
		fi
	fi
}

__np_rdio() {
	[ ! shell_is_osx ] && return 1
	np=$(osascript ${TMUX_POWERLINE_DIR_SEGMENTS}/np_rdio_mac.script)
	echo "$np"
}

__np_rhythmbox() {
	rhythmbox_pid=$(pidof rhythmbox)
	if [ -n "$rhythmbox_pid" ]; then
		np=$(rhythmbox-client --no-start --print-playing-format="$TMUX_POWERLINE_SEG_NOW_PLAYING_RHYTHMBOX_FORMAT")
		rhythmbox_paused=$(xwininfo -root -tree | grep "$np" | sed "s/${np}//;s/ //g" | cut -f2 -d '"')
		# TODO I cant produce the output "Not playing", using rhythmbox 2.97.
		#STATUS=$(rhythmbox-client --no-start --print-playing)
		if [[ "$rhythmbox_paused" != "(Paused)" ]]; then
			echo "$np"
		fi
	fi
}

__np_spotify() {
	if shell_is_linux; then
		metadata=$(dbus-send --reply-timeout=42 --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' 2>/dev/null)
		if [ "$?" -eq 0 ] && [ -n "$metadata" ]; then
			# TODO how do one express this with dbus-send? It works with qdbus but the problem is that it's probably not as common as dbus-send.
			state=$(qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus)
			if [[ $state == "Playing" ]]; then
				artist=$(echo "$metadata" | grep -PA2 "string\s\"xesam:artist\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				track=$(echo "$metadata" | grep -PA1 "string\s\"xesam:title\"" | tail -1 | grep -Po "(?<=\").*(?=\")")
				np=$(echo "${artist} - ${track}")
			fi
		fi
	elif shell_is_osx; then
		np=$(${TMUX_POWERLINE_DIR_SEGMENTS}/np_spotify_mac.script)
	fi
	echo "$np"
}

__np_spotify_wine() {
	[ ! shell_is_linux ] && return 1
	spotify_id=$(xwininfo -root -tree | grep '("spotify' | cut -f1 -d'"' | sed 's/ //g')
	echo $spotify_id
	if [ -n "$spotify_id" ]; then
		np=$(xwininfo -id "$spotify_id" | grep "xwininfo.*Spotify -" | grep -Po "(?<=\"Spotify - ).*(?=\"$)")
		echo "$np"
	fi
}
