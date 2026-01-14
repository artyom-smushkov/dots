#!/usr/bin/env bash

SESSION_NAME="piiq-local"
LOCAL_PATH="/home/templarrr/Development/piiq-dev-containers"
SESSION_FILE="/tmp/${SESSION_NAME}.kitty-session"

cd "$LOCAL_PATH" || exit 1

is_running=$(docker compose ps | grep Up)
if [ -z "$is_running" ]; then
    docker compose up -d --build
    for i in {10..1}; do
        echo "$i..."
        sleep 1
    done
fi

kitty --title "$SESSION_NAME" --session ~/.config/kitty/sessions/piiq.session >/dev/null 2>&1 & disown
