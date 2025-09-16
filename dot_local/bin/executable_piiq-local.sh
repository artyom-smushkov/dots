#!/usr/bin/env bash
SESSION_NAME="piiq-local"
LOCAL_PATH="/home/templarrr/Development/piiq-dev-containers"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    cd "$LOCAL_PATH"
    is_running=$(docker compose ps | grep Up)
    if [ -z "$is_running" ]; then
        docker compose up -d --build
        echo "10..."
        sleep 1
        echo "9..."
        sleep 1
        echo "8..."
        sleep 1
        echo "7..."
        sleep 1
        echo "6..."
        sleep 1
        echo "5..."
        sleep 1
        echo "4..."
        sleep 1
        echo "3..."
        sleep 1
        echo "2..."
        sleep 1
        echo "1..."
        sleep 1
    fi

    tmux send-keys -t "$SESSION_NAME:0" "docker exec -it piiq /home/linuxbrew/.linuxbrew/bin/fish" Enter
    tmux rename-window -t "$SESSION_NAME:0" " shell"

    tmux new-window -t "$SESSION_NAME" -n " runserver"
    tmux send-keys -t "$SESSION_NAME:1" "docker exec -it piiq /home/linuxbrew/.linuxbrew/bin/fish" Enter
    sleep 0.05
    tmux send-keys -t "$SESSION_NAME:1" "python app/manage.py runserver 0.0.0.0:8000" Enter

    tmux new-window -t "$SESSION_NAME" -n " taskmanager"
    tmux send-keys -t "$SESSION_NAME:2" "docker exec -it piiq /home/linuxbrew/.linuxbrew/bin/fish" Enter
    sleep 0.05
    tmux send-keys -t "$SESSION_NAME:2" "python app/manage.py start_task_manager 10 --single-process" Enter

    tmux new-window -t "$SESSION_NAME" -n " frontend"
    tmux send-keys -t "$SESSION_NAME:3" "docker exec -it piiq /home/linuxbrew/.linuxbrew/bin/fish" Enter
    sleep 0.05
    tmux send-keys -t "$SESSION_NAME:3" "cd app/frontend" Enter
    sleep 0.05
    tmux send-keys -t "$SESSION_NAME:3" "npm run watch" Enter

    tmux select-window -t "$SESSION_NAME:0"
fi

if [ -n $TMUX ]; then
    tmux switch-client -t "$SESSION_NAME"
else
    tmux attach -t "$SESSION_NAME"
fi
