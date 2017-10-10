# Indicator of pressing TMUX prefix, copy and insert modes.

PREFIX="☹"
INSERT=" "
COPY=""
NORM=" "
SEP=" "

PREFIX_FG="colour4"
NORM_FG="colour0"
COPY_FG="colour5"
bg="colour0"

run_segment() {
    prefix_indicator="#{?client_prefix,#[fg=${PREFIX_FG}]${PREFIX},#[fg=${NORM_FG}]${NORM}}"
    mode_indicator="#{?pane_in_mode,#[fg=${COPY_FG}]${COPY},${INSERT}}"
    echo $prefix_indicator"#[fg=${NORM_FG}]${SEP}"$mode_indicator""
    return 0
}
