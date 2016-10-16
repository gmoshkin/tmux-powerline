# Print the storage capacity of the file system.

TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN_DEFAULT="boot"
TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN_DEFAULT="NONE"
TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN_DEFAULT="home"

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

EORC
    echo "$rccontents"
}

get_data() {
    df -h | awk "
    /$TMUX_POWERLINE_SEG_STORAGE_BOOT_PATTERN/ { boot = \$4 }
    /$TMUX_POWERLINE_SEG_STORAGE_ROOT_PATTERN/ { root = \$4 \"/\" \$2 }
    /$TMUX_POWERLINE_SEG_STORAGE_HOME_PATTERN/ { home = \$4 \"/\" \$2 }
    END {
        res = \"\"
        res = res boot
        if (root) {
            if (res) {
                res = res \" | \" root
            } else {
                res = root
            }
        }
        if (home) {
            if (res) {
                res = res \" | \" home
            } else {
                res = home
            }
        }
        print res
        # print boot, \"|\", root, \"|\", home
    }
    "
}

run_segment() {
    get_data | head -1 # usefull for debugging purposes
    exit 0
}
