#!/usr/bin/env bash
# Install and configure XFCE, TigerVNC and noVNC.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

DO_PACKAGES=true
DO_CONFIG=true

case "${1:-}" in
    --packages-only)
        DO_CONFIG=false
        ;;
    --config-only)
        DO_PACKAGES=false
        ;;
    "")
        ;;
    *)
        die "Unknown option: $1"
        ;;
esac

install_packages() {
    local sudo_cmd=()

    if [[ "${EUID}" -ne 0 ]]; then
        require_cmd sudo
        sudo_cmd=(sudo)
    fi

    require_cmd apt-get

    log "Updating package lists..."
    export DEBIAN_FRONTEND=noninteractive
    "${sudo_cmd[@]}" apt-get update

    log "Installing XFCE, TigerVNC and noVNC..."

    "${sudo_cmd[@]}" apt-get install -y --no-install-recommends \
        xfce4 \
        xfce4-terminal \
        thunar \
        mousepad \
        tigervnc-standalone-server \
        tigervnc-common \
        tigervnc-tools \
        novnc \
        websockify \
        dbus-x11 \
        x11-xserver-utils \
        xauth \
        xfonts-base \
        ca-certificates \
        fonts-dejavu

    log "Package installation completed."
}

configure_vnc() {
    require_cmd tigervncpasswd
    require_vnc_password

    if (( ${#VNC_PASSWORD} < 6 )); then
        die "VNC_PASSWORD must contain at least 6 characters."
    fi

    log "Configuring TigerVNC for user ${USER:-$(whoami)}..."

    mkdir -p "${HOME}/.vnc"
    chmod 700 "${HOME}/.vnc"

    if [[ ! -f "${CLOUDPC_ROOT}/config/xstartup" ]]; then
        die "Missing desktop startup file: ${CLOUDPC_ROOT}/config/xstartup"
    fi

    install -m 0755 \
        "${CLOUDPC_ROOT}/config/xstartup" \
        "${HOME}/.vnc/xstartup"

    # Generate the TigerVNC password file without exposing the secret
    # as a command-line argument.
    umask 077
    printf '%s\n' "${VNC_PASSWORD}" |
        tigervncpasswd -f > "${HOME}/.vnc/passwd"

    chmod 600 "${HOME}/.vnc/passwd"

    log "TigerVNC password and XFCE startup configuration installed."
}

if [[ "${DO_PACKAGES}" == true ]]; then
    install_packages
fi

if [[ "${DO_CONFIG}" == true ]]; then
    configure_vnc
fi

log "Desktop setup finished successfully."
