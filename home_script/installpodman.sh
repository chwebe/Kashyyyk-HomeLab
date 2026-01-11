#!/usr/bin/env bash
set -euo pipefail

# Install Podman and enable socket
sudo pacman -S --noconfirm podman podman-compose podman-docker

# Enable podman socket
sudo systemctl enable --now podman.socket


