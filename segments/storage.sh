# Print the storage capacity of /space directory.

run_segment() {
    df -h | awk '
    /sda3/ { root = $4 }
    /boot/ { boot = $4 }
    /space/ { space = $4 "/" $2 }
    END { print root, "|", boot, "|", space }
    '
    exit 0
}
