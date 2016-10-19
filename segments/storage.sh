# Print the storage capacity of the file system.

TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN_DEFAULT="boot"
TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN_DEFAULT="ROOT"
TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN_DEFAULT="home"
TMUX_POWERLINE_SEG_STORAGE_DELIMITER_DEFAULT=""
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

EORC
    echo "$rccontents"
}

get_data() {
    df -h | awk "
    /$TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN/ { boot = \$4 }
    $TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN { root = \$4 \"/\" \$2 }
    /$TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN/ { home = \$4 \"/\" \$2 }
    END {
        res = \"\"
        res = res boot
        if (root) {
            if (res) {
                res = res \" $TMUX_POWERLINE_SEG_STORAGE_DELIMITER \" root
            } else {
                res = root
            }
        }
        if (home) {
            if (res) {
                res = res \" $TMUX_POWERLINE_SEG_STORAGE_DELIMITER \" home
            } else {
                res = home
            }
        }
        print res
        # print boot, \"$TMUX_POWERLINE_SEG_STORAGE_DELIMITER\", root, \"$TMUX_POWERLINE_SEG_STORAGE_DELIMITER\", home
    }
    "
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
