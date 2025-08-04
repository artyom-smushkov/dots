#!/usr/bin/env bash
LIMIT=$(tmux show-option -gqv history-limit)
WIDTH=$(tmux display -p -F "#{pane_width}")
SELECTED=$(tmux capture-pane -p -S "-$LIMIT" | fold -s -w $WIDTH | nl -ba | fzf --tmux)

if [ -n "$SELECTED" ]; then
    LINE_NUMBER=$(echo $SELECTED | awk '{print $1}')
    OFFSET=$(($LINE_NUMBER-1))

    tmux copy-mode
    tmux send-keys -X history-top
    tmux send-keys -X -N $OFFSET cursor-down
fi
