# Print the storage capacity of the file system.

TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN_DEFAULT="boot"
TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN_DEFAULT="ROOT"
TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN_DEFAULT="home"
TMUX_POWERLINE_SEG_STORAGE_DELIMITER_DEFAULT=""
TMUX_POWERLINE_SEG_STORAGE_BOOT_SYMBOL_DEFAULT="👢"
TMUX_POWERLINE_SEG_STORAGE_ROOT_SYMBOL_DEFAULT="√"
TMUX_POWERLINE_SEG_STORAGE_HOME_SYMBOL_DEFAULT="🏠"
TMUX_POWERLINE_SEG_STORAGE_BOOT_THRESHOLD_DEFAULT="50M"
TMUX_POWERLINE_SEG_STORAGE_ROOT_THRESHOLD_DEFAULT="0.1"
TMUX_POWERLINE_SEG_STORAGE_HOME_THRESHOLD_DEFAULT="0.1"
DEFAULT_ROOT_PATTERN="\$6 == \"/\""

generate_segmentrc() {
    read -d '' rccontents  << EORC
# Boot partition pattern
export TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN="${TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN_DEFAULT}"
# Can be "NONE" if not needed.
# Root partition pattern
export TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN="${TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN_DEFAULT}"
# Can be "NONE" if not needed.
# Home partition pattern
export TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN="${TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN_DEFAULT}"
# Can be "NONE" if not needed.
# Delimiter character
export TMUX_POWERLINE_SEG_STORAGE_DELIMITER="${TMUX_POWERLINE_SEG_STORAGE_DELIMITER_DEFAULT}"
# Boot symbol
export TMUX_POWERLINE_SEG_STORAGE_BOOT_SYMBOL="${TMUX_POWERLINE_SEG_STORAGE_BOOT_SYMBOL_DEFAULT}"
# Root symbol
export TMUX_POWERLINE_SEG_STORAGE_ROOT_SYMBOL="${TMUX_POWERLINE_SEG_STORAGE_ROOT_SYMBOL_DEFAULT}"
# Home symbol
export TMUX_POWERLINE_SEG_STORAGE_HOME_SYMBOL="${TMUX_POWERLINE_SEG_STORAGE_HOME_SYMBOL_DEFAULT}"
# Boot threshold
export TMUX_POWERLINE_SEG_STORAGE_BOOT_THRESHOLD="${TMUX_POWERLINE_SEG_STORAGE_BOOT_THRESHOLD_DEFAULT}"
# Root threshold
export TMUX_POWERLINE_SEG_STORAGE_ROOT_THRESHOLD="${TMUX_POWERLINE_SEG_STORAGE_ROOT_THRESHOLD_DEFAULT}"
# Home threshold
export TMUX_POWERLINE_SEG_STORAGE_HOME_THRESHOLD="${TMUX_POWERLINE_SEG_STORAGE_HOME_THRESHOLD_DEFAULT}"

EORC
    echo "$rccontents"
}

get_data() {
    df -h | awk "
    function get_fac(str) {
        return substr(str, length(str), 1)
    }
    function get_val(str) {
        return substr(str, 1, length(str) - 1) + 0
    }
    function threshold(str, thresh, symbol) {
        factor = get_fac(str)
        value = get_val(str)
        thresh_factor = get_fac(thresh)
        thresh_value = get_val(thresh)
        if (factor && (factor == \"K\" ||
                       (factor == thresh_factor &&
                        value + 0 <= thresh_value))) {
            return symbol \" \" value factor
        } else {
            return \"\"
        }
    }
    function fraction_threshold(str1, str2, frac_thresh, symbol) {
        fac1 = get_fac(str1)
        val1 = get_val(str1)
        fac2 = get_fac(str2)
        val2 = get_val(str2)
        if (fac1 != fac2 || val1 / val2 <= frac_thresh + 0) {
            return symbol \" \" val1 fac1 \"/\" val2 fac2
        } else {
            return \"\"
        }
    }
    /$TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN/ {
        boot = threshold(\$4, \"$TMUX_POWERLINE_SEG_STORAGE_BOOT_THRESHOLD\", \"$TMUX_POWERLINE_SEG_STORAGE_BOOT_SYMBOL\")
    }
    $TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN {
        root = fraction_threshold(\$4, \$2, \"$TMUX_POWERLINE_SEG_STORAGE_ROOT_THRESHOLD\", \"$TMUX_POWERLINE_SEG_STORAGE_ROOT_SYMBOL\")
    }
    /$TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN/ {
        home = fraction_threshold(\$4, \$2, \"$TMUX_POWERLINE_SEG_STORAGE_HOME_THRESHOLD\", \"$TMUX_POWERLINE_SEG_STORAGE_HOME_SYMBOL\")
    }
    END {
        res = \"\"
        res = res boot
        if (root) {
            if (res) {
                res = res \" $TMUX_POWERLINE_SEG_STORAGE_DELIMITER \"
            }
            res = res root
        }
        if (home) {
            if (res) {
                res = res \" $TMUX_POWERLINE_SEG_STORAGE_DELIMITER \"
            }
            res = res home
        }
        print res
        # print boot, \"$TMUX_POWERLINE_SEG_STORAGE_DELIMITER\", root, \"$TMUX_POWERLINE_SEG_STORAGE_DELIMITER\", home
    }
    " 2> $TMUX_POWERLINE_DIR_TEMPORARY/storage.txt
    echo $TMUX_POWERLINE_SEG_STORAGE_HOME_SYMBOL
}

run_segment() {
    if [ "$TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN" == "ROOT" ]; then
        TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN="$DEFAULT_ROOT_PATTERN"
    else
        TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN="/$TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN/"
    fi
    get_data | head -1 # usefull for debugging purposes
    exit 0
}
