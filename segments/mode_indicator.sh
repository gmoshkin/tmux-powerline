# Indicator of pressing TMUX prefix, copy and insert modes.

PREFIX="☹"
INSERT=" "
SELECT="★"
COPY="★"
NORM=" "
SEP=" "

bg="colour0"
PREFIX_FG="colour4"
NORM_FG="$bg"
COPY_FG="colour2"
SELECT_FG="colour5"
INSERT_FG="$bg"

PREFIX_FORMAT="#[fg=${PREFIX_FG}]${PREFIX}"
NORM_FORMAT="#[fg=${NORM_FG}]${NORM}"
SELECT_FORMAT="#[fg=${SELECT_FG}]${SELECT}"
COPY_FORMAT="#[fg=${COPY_FG}]${COPY}"
SEL_COP_FORMAT="#{?selection_present,$SELECT_FORMAT,$COPY_FORMAT}"
INSERT_FORMAT="#[fg=${INSERT_FG}]${INSERT}"

run_segment() {
    prefix_indicator="#{?client_prefix,$PREFIX_FORMAT,$NORM_FORMAT}"
    mode_indicator="#{?pane_in_mode,$SEL_COP_FORMAT,$INSERT_FORMAT}"
    echo $prefix_indicator"#[fg=${NORM_FG}]${SEP}"$mode_indicator""
    return 0
}
