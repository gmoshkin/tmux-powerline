run_segment() {
    echo $(tmux display-message -p '#{session_width}')
}
