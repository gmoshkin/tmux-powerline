# Prints the current USD and EUR prices in RUR. The data is cached and updated
# with a period of $TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD.

TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER_DEFAULT="rbc"
TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_USD_DEFAULT="yes"
TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL_DEFAULT="$"
TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_EUR_DEFAULT="yes"
TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL_DEFAULT="€"
# The update period in seconds.
TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD_DEFAULT="600"


generate_segmentrc() {
	read -d '' rccontents  << EORC
# The data provider to use. Currently only "rbc" is supported.
export TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER="${TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER_DEFAULT}"
# Can be either of {"yes", "no"}.
export TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_USD="${TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_USD_DEFAULT}"
# What symbol to show next to the currency.
export TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL="${TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL_DEFAULT}"
# Can be either of {"yes", "no"}.
export TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_EUR="${TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_EUR_DEFAULT}"
# What symbol to show next to the currency.
export TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL="${TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL_DEFAULT}"
# How often to update the data in seconds.
export TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD_DEFAULT}"

EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/currency_${TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER}.txt"
	local currency
	case "$TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER" in
		"rbc") currency=$(__rbc_currency) ;;
		*)
			echo "Unknown data provider [${$TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER}]";
			return 1
	esac
	if [ -n "$currency" ]; then
		echo "$currency"
	fi
}

__process_settings() {
	if [ -z "${TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER}" ]; then
		export TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER="${TMUX_POWERLINE_SEG_CURRENCY_DATA_PROVIDER_DEFAULT}"
	fi
	if [ -z "${TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_USD}" ]; then
		export TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_USD="${TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_USD_DEFAULT}"
	fi
	if [ -z "${TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL}" ]; then
		export TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL="${TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL_DEFAULT}"
	fi
	if [ -z "${TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_EUR}" ]; then
		export TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_EUR="${TMUX_POWERLINE_SEG_CURRENCY_DISPLAY_EUR_DEFAULT}"
	fi
	if [ -z "${TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL}" ]; then
		export TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL="${TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL_DEFAULT}"
	fi
	if [ -z "${TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD}" ]; then
		export TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD_DEFAULT}"
	fi
}

__rbc_currency() {
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" ${tmp_file})
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" ${tmp_file})
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_CURRENCY_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	data=$(curl --max-time 4 "http://www.rbc.ru")
	if [ "$?" -eq "0" ]; then
		currency=$(echo ${data} | awk '
		BEGIN {
			RS = "</";
			FS = ">";
			ORS = " ";
		}
		/Нал. USD/ {
			USD = NR + 1;
		}
		NR == USD {
			print "'${TMUX_POWERLINE_SEG_CURRENCY_USD_SYMBOL}'" $3;
		}
		/Нал. EU/ {
			EUR = NR + 1;
		}
		NR == EUR {
			print "'${TMUX_POWERLINE_SEG_CURRENCY_EUR_SYMBOL}'" $3;
		}')
		echo ${currency} > ${tmp_file}
		echo `date` >> ${tmp_file}
		echo ${currency}
	elif [ -f "${tmp_file}" ]; then
		__read_tmp_file
	fi
}

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	head -1 "${tmp_file}"
	exit
}
