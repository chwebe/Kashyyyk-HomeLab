mkdir -p keys
ssh-keygen -t ed25519 -C "chwebe" -f keys/id_ed25519

# copy key to remote host
ssh-copy-id -i keys/id_ed25519.pub chweadm@192.168.1.13

#!/usr/bin/env bash
set -euo pipefail

HOST_IP="192.168.1.13"
HOST_USER="chweadm"
ID_FILE="/opt/git/Kashyyyk-HomeLab/keys/id_ed25519"

SSH_DIR="$HOME/.ssh"
CFG_FILE="$SSH_DIR/config"
TMP_FILE="$CFG_FILE.tmp"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$CFG_FILE"
chmod 600 "$CFG_FILE"

# Remove any existing block for this host (from 'Host <ip>' up to next 'Host ' or EOF)
awk -v host="$HOST_IP" '
  BEGIN { skip=0 }
  # start of a host block
  /^Host[[:space:]]+/ {
    # if we were skipping and encounter a new Host, stop skipping
    if (skip==1) { skip=0 }
    # check if this is the host to remove
    if ($2==host) { skip=1; next }
  }
  skip==0 { print }
' "$CFG_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CFG_FILE"

# Append the desired canonical block
{
  echo ""
  echo "Host $HOST_IP"
  echo "  User $HOST_USER"
  echo "  IdentityFile $ID_FILE"
} >> "$CFG_FILE"