#!/bin/bash

set -ouex pipefail


sudo snapper -c root create --type auto
sudo eix-sync
sudo emerge -avDNu @world
flatpak upgrade
