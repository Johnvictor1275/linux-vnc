#!/usr/bin/env bash
# Install and/or configure XFCE + TigerVNC + noVNC.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

DO_PACKAGES=true
DO_CONFIG=true
case "${1:-}" in
  --packages-only) DO_CONFIG=false ;;
  --config-only)   DO_PACKAGES=false ;;
  "")              ;;
  *)               die "Unknown option: $1" ;;
esac

install_packages() {
  local sudo_cmd=()
  if [[ "${EUID}" -ne 0 ]]; then
    require_cmd sudo
    sudo_cmd=(sudo)
  fi

  log "Installing XFCE, TigerVNC and noVNC..."
  export DEBIAN_FRONTEND=noninteractive
  "${sudo_cmd[@]}" apt-get update
  "${sudo_cmd[@]}" apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal thunar mousepad \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    novnc websockify \
    dbus-x11 x11-xserver-utils xauth xfonts-base \
    ca-certificates fonts-dejavu
}

configure_vnc() {
  require_cmd tigervncpasswd
  [[ -n "${VNC_PASSWORD}" ]] || die "VNC_PASSWORD is empty. Configure the Codespaces secret; do not store it in a repository file."

  log "Configuring TigerVNC for ${USER:-$(whoami)}..."
  mkdir -p "${HOME}/.vnc"
  install -m 0755 "${CLOUDPC_ROOT}/config/xstartup" "${HOME}/.vnc/xstartup"

  # TigerVNC's traditional password file stores at most the first 8 characters.
  printf '%s\n' "${VNC_PASSWORD}" | tigervncpasswd -f > "${HOME}/.vnc/passwd"
  chmod 600 "${HOME}/.vnc/passwd"

  if [[ "${NOVNC_TLS}" == "true" && ! -f "${HOME}/novnc.pem" ]]; then
    require_cmd openssl
    log "Generating a self-signed noVNC certificate..."
    openssl req -x509 -nodes -newkey rsa:3072 \
      -keyout "${HOME}/novnc.pem" -out "${HOME}/novnc.pem" \
      -days 3650 -subj "/CN=localhost" >/dev/null 2>&1
    chmod 600 "${HOME}/novnc.pem"
  fi
}

if [[ "${DO_PACKAGES}" == true ]]; then install_packages; fi
if [[ "${DO_CONFIG}" == true ]]; then configure_vnc; fi

log "Desktop setup finished."
