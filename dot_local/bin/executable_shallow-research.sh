#!/usr/bin/env bash
SESSION_NAME="shallow-research"
LOCAL_PATH="/home/templarrr/Development/shallow-research/"

cd "$LOCAL_PATH"
COMPOSE_IS_RUNNING=$(docker compose -f docker-compose-dev.yml ps --format json 2>/dev/null | grep -q '"State":"running"' && echo "yes")
if [ -z $COMPOSE_IS_RUNNING ]; then
    docker compose -f docker-compose-dev.yml up -d --build
fi

wezterm --config-file ~/.config/wezterm/workspaces/shallow-research.lua start --always-new-process &2>1 & disown
