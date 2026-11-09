#!/usr/bin/env bash
# Start the XFCE TigerVNC desktop and noVNC proxy.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

log "Checking desktop configuration..."

validate_desktop_config
require_vnc_password

require_cmd tigervncserver websockify tigervncpasswd pgrep

NOVNC_WEB_ROOT="/usr/share/novnc"

if [[ ! -d "${NOVNC_WEB_ROOT}" ]]; then
    die "noVNC web directory not found: ${NOVNC_WEB_ROOT}"
fi

if [[ ! -f "${HOME}/.vnc/passwd" ]]; then
    die "TigerVNC password file is missing. Run: bash scripts/setup-desktop.sh --config-only"
fi

chmod 700 "${HOME}/.vnc"
chmod 600 "${HOME}/.vnc/passwd"

mkdir -p "${HOME}/.logs"

# Start TigerVNC if the requested session is not already running.
if ! tigervncserver -list 2>/dev/null |
    grep -Fq ":${VNC_DISPLAY}"; then

    log "Starting TigerVNC display :${VNC_DISPLAY}..."

    tigervncserver \
        ":${VNC_DISPLAY}" \
        -rfbport "${VNC_PORT}" \
        -localhost yes \
        -geometry "${VNC_GEOMETRY}" \
        -depth "${VNC_DEPTH}" \
        -SecurityTypes VncAuth
else
    log "TigerVNC display :${VNC_DISPLAY} is already running."
fi

# Start the noVNC WebSocket proxy if it is not already running.
if ! pgrep -f "[w]ebsockify.*${NOVNC_PORT}" >/dev/null 2>&1; then
    log "Starting noVNC on port ${NOVNC_PORT}..."

    nohup websockify \
        --web="${NOVNC_WEB_ROOT}" \
        "127.0.0.1:${NOVNC_PORT}" \
        "127.0.0.1:${VNC_PORT}" \
        > "${HOME}/.logs/novnc.log" 2>&1 &

    NOVNC_PID=$!

    sleep 2

    if ! kill -0 "${NOVNC_PID}" 2>/dev/null; then
        die "noVNC failed to start. Check ${HOME}/.logs/novnc.log"
    fi
else
    log "noVNC is already running."
fi

log "Desktop startup completed."
log "Display: :${VNC_DISPLAY}"
log "VNC port: ${VNC_PORT} (localhost only)"
log "noVNC port: ${NOVNC_PORT} (localhost only)"
