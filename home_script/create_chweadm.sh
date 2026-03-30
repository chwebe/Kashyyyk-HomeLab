#!/usr/bin/env bash
# =============================================================================
# setup_chweadm.sh
# Creates the 'chweadm' infrastructure user on an Arch Linux laptop.
# - No sudo privileges
# - SSH key copied from current user (for Pi 4 access)
# - VSCode installed via pacman
# - SSH config scoped to Pi 4 only
#
# Usage: sudo bash create_chweadm.sh
# =============================================================================

set -euo pipefail

# --- Constants ----------------------------------------------------------------
INFRA_USER="chweadm"
CALLING_USER="${SUDO_USER:-}"                 # The user who called sudo
RASPI_HOST="192.168.1.13"                      # Replace with your Pi 4 IP
RASPI_HOSTNAME="coruscant02"
RASPI_SSH_PORT="4822"                         # Replace with your SSH port
RASPI_TARGET_USER="chweadm"                  # Replace with your Pi 4 admin user

# --- Colours ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# --- Preflight checks ---------------------------------------------------------
if [[ "${EUID}" -ne 0 ]]; then
  error "This script must be run as root: sudo bash create_chweadm.sh"
fi

if [[ -z "${CALLING_USER}" ]]; then
  error "Could not determine the calling user. Run with sudo, not as root directly."
fi

CALLING_USER_HOME=$(getent passwd "${CALLING_USER}" | cut -d: -f6)
SOURCE_KEY="/opt/git/Kashyyyk-HomeLab/keys/id_ed25519"

if [[ ! -f "${SOURCE_KEY}" ]]; then
  # Fallback to RSA if ed25519 not found
  SOURCE_KEY="${CALLING_USER_HOME}/.ssh/id_rsa"
  if [[ ! -f "${SOURCE_KEY}" ]]; then
    error "No SSH key found at ${CALLING_USER_HOME}/.ssh/id_ed25519 or id_rsa. Generate one first."
  fi
  warn "ed25519 key not found, falling back to: ${SOURCE_KEY}"
fi

info "Source SSH key: ${SOURCE_KEY}"
info "Calling user:   ${CALLING_USER}"

# --- 1. Create the user -------------------------------------------------------
info "Creating user '${INFRA_USER}'..."

if id "${INFRA_USER}" &>/dev/null; then
  warn "User '${INFRA_USER}' already exists — skipping creation."
else
  useradd \
    --create-home \
    --shell /bin/bash \
    --comment "HomeLab admin user" \
    "${INFRA_USER}"
  passwd "${INFRA_USER}"                      # Prompts for password interactively
  info "User '${INFRA_USER}' created."
fi

INFRA_HOME=$(getent passwd "${INFRA_USER}" | cut -d: -f6)

# --- 2. Set up SSH directory --------------------------------------------------
info "Setting up SSH directory..."

mkdir -p "${INFRA_HOME}/.ssh"
chmod 700 "${INFRA_HOME}/.ssh"

# Copy the SSH private key
KEY_FILENAME=$(basename "${SOURCE_KEY}")
cp "${SOURCE_KEY}" "${INFRA_HOME}/.ssh/${KEY_FILENAME}"
chmod 600 "${INFRA_HOME}/.ssh/${KEY_FILENAME}"

# Copy the public key if it exists
if [[ -f "${SOURCE_KEY}.pub" ]]; then
  cp "${SOURCE_KEY}.pub" "${INFRA_HOME}/.ssh/${KEY_FILENAME}.pub"
  chmod 644 "${INFRA_HOME}/.ssh/${KEY_FILENAME}.pub"
fi

# --- 3. Write SSH config scoped to Pi 4 only ---------------------------------
info "Writing SSH config..."

cat > "${INFRA_HOME}/.ssh/config" <<EOF
# Managed by create_chweadm.sh — infrastructure access only

Host ${RASPI_HOSTNAME}
    HostName ${RASPI_HOST}
    User ${RASPI_TARGET_USER}
    Port ${RASPI_SSH_PORT}
    IdentityFile ~/.ssh/${KEY_FILENAME}
    IdentitiesOnly yes
    ServerAliveInterval 120
    ServerAliveCountMax 3

# Block all other SSH connections from this user
Host *
    IdentityFile none
    IdentitiesOnly yes
EOF

chmod 600 "${INFRA_HOME}/.ssh/config"

# --- 4. Fix ownership of all .ssh files --------------------------------------
chown -R "${INFRA_USER}:${INFRA_USER}" "${INFRA_HOME}/.ssh"
info "SSH config written."

# --- 5. Install VSCode via pacman --------------------------------------------
info "Installing VSCode..."

if pacman -Qi code &>/dev/null; then
  warn "VSCode (code) is already installed — skipping."
else
  pacman -Sy --noconfirm code
  info "VSCode installed."
fi

# --- 6. Configure VSCode Remote SSH extension for chweadm -------------------
info "Setting up VSCode Remote SSH extension..."

VSCODE_EXTENSIONS_DIR="${INFRA_HOME}/.vscode/extensions"
mkdir -p "${VSCODE_EXTENSIONS_DIR}"

# Install Remote SSH extension for chweadm user
sudo -u "${INFRA_USER}" code \
  --extensions-dir "${VSCODE_EXTENSIONS_DIR}" \
  --install-extension ms-vscode-remote.remote-ssh \
  --force 2>/dev/null || warn "VSCode extension install failed — run manually as ${INFRA_USER}: code --install-extension ms-vscode-remote.remote-ssh"

chown -R "${INFRA_USER}:${INFRA_USER}" "${INFRA_HOME}/.vscode"

# --- 7. Write a minimal .bashrc for chweadm ----------------------------------
info "Writing .bashrc..."

cat >> "${INFRA_HOME}/.bashrc" <<'EOF'

# --- chweadm infra environment ------------------------------------------------
export PS1='\[\033[01;31m\][infra]\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\$ '

alias ${RASPI_HOSTNAME}='ssh -p ${RASPI_SSH_PORT} ${RASPI_HOSTNAME}'

echo ""
echo "  Infrastructure shell — chweadm"
echo "  SSH targets: ${RASPI_HOSTNAME}"
echo "  Tip: type '${RASPI_HOSTNAME}' to connect"
echo ""
EOF

chown "${INFRA_USER}:${INFRA_USER}" "${INFRA_HOME}/.bashrc"

# --- 8. Verify no sudo access -------------------------------------------------
info "Verifying no sudo privileges for '${INFRA_USER}'..."

if groups "${INFRA_USER}" | grep -qE '\bsudo\b|\bwheel\b'; then
  warn "'${INFRA_USER}' is in sudo/wheel group — removing..."
  gpasswd -d "${INFRA_USER}" sudo  2>/dev/null || true
  gpasswd -d "${INFRA_USER}" wheel 2>/dev/null || true
  info "Removed from privileged groups."
else
  info "'${INFRA_USER}' has no sudo privileges. ✓"
fi

# --- Done ---------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN} Setup complete for user: ${INFRA_USER}${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  Next steps:"
echo "  1. Switch to the infra user:       su - ${INFRA_USER}"
echo "  2. Test SSH connection:            ssh ${RASPI_HOSTNAME}"
echo "  3. Open VSCode for infra work:     code"
echo "  4. Update RASPI_HOST in this script if the IP changes"
echo ""
echo -e "${YELLOW}  IMPORTANT: Make sure your Pi 4 has your public key in${NC}"
echo -e "${YELLOW}  authorized_keys before testing SSH.${NC}"
echo ""