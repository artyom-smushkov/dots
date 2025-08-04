#!/usr/bin/env bash

SESSION_NAME="piiq-remotes"

WINDOW_NAME=$(
echo "jumpserver
stage
stage-mongo
worker1
worker2
worker3
worker4
webserver
cronserver
mongosync
dev1
dev2
dev3
dev4
dev5" | fzf --tmux)

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:0" " $WINDOW_NAME"
    tmux send-keys -t "$SESSION_NAME: $WINDOW_NAME" "ssh piiq-$WINDOW_NAME" Enter
else
    if ! tmux list-windows -t "$SESSION_NAME" | grep " $WINDOW_NAME" 2>/dev/null; then
        tmux new-window -t "$SESSION_NAME" -n " $WINDOW_NAME"
        tmux send-keys -t "$SESSION_NAME: $WINDOW_NAME" "ssh piiq-$WINDOW_NAME" Enter
    fi
fi

if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$SESSION_NAME"
else
    tmux attach -t "$SESSION_NAME"
fi
