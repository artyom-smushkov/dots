#!/usr/bin/env bash
SESSION_NAME="shallow-research"
LOCAL_PASH="/var/home/templarrr/development/shallow-research/"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    cd "$LOCAL_PASH"
    is_running=$(docker compose -f docker-compose-dev.yml ps | grep up)
    if [ -z "$is_running" ]; then
        docker compose -f docker-compose-dev.yml up -d --build
    fi

    tmux send-keys -t "$SESSION_NAME:0" "docker exec -it shallow_research_dev /bin/fish" enter
    tmux rename-window -t "$SESSION_NAME:0" " shell"

    tmux new-window -t "$SESSION_NAME" -n " server"
    tmux send-keys -t "$SESSION_NAME:1" "docker exec -it shallow_research_dev /bin/fish" enter
    sleep 0.05
    tmux send-keys -t "$SESSION_NAME:1" "python src/shallow-research.py" enter

    tmux select-window -t "$SESSION_NAME:0"
fi

if [ -n $TMUX ]; then
    tmux switch-client -t "$SESSION_NAME"
else
    tmux attach -t "$SESSION_NAME"
fi
