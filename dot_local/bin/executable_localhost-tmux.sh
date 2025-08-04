#!/usr/bin/env bash
SESSION_NAME="localhost"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:0" " shell"
fi

tmux attach -t "$SESSION_NAME"
