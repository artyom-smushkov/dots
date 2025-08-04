piiq:
	#!/bin/bash
	cd ~/Development/piiq-dev-containers
	is_running=$(docker compose ps | grep Up)
	if [ -z "$is_running" ]; then
	    docker compose up -d --build
	fi
	docker exec -it piiq /bin/fish
stop-piiq:
	#!/bin/bash
	cd ~/Development/piiq-dev-containers
	docker compose down
# You can add your own commands here! For documentation, see: https://ublue.it/guide/just/
import "/usr/share/ublue-os/justfile"
