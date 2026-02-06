#!/usr/bin/env bash
SESSION_NAME="crypto_nonsence"
LOCAL_PATH="/home/templarrr/Development/crypto-nonsence/"

cd "$LOCAL_PATH"
COMPOSE_IS_RUNNING=$(docker compose -f docker-compose-dev.yml ps --format json 2>/dev/null | grep -q '"State":"running"' && echo "yes")
if [ -z $COMPOSE_IS_RUNNING ]; then
    docker compose -f docker-compose-dev.yml up -d --build
fi
MINIKUBE_IS_RUNNING=$(minikube status 2>/dev/null | grep -q "host: Running" && echo "yes")
if [ -z $MINIKUBE_IS_RUNNING ]; then
    minikube start --cpus=4 --memory=8192
fi

wezterm --config-file ~/.config/wezterm/workspaces/crypto-nonsence.lua start --always-new-process &2>1 & disown
