#!/usr/bin/env bash
# Stop the noVNC proxy and TigerVNC desktop.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

validate_desktop_config

log "Stopping noVNC on port ${NOVNC_PORT}..."

# Stop only the websockify process serving this noVNC port.
if pgrep -f "[w]ebsockify.*${NOVNC_PORT}" >/dev/null 2>&1; then
    pkill -f "[w]ebsockify.*${NOVNC_PORT}" || true
    log "noVNC proxy stopped."
else
    log "No noVNC proxy was running."
fi

log "Stopping TigerVNC display :${VNC_DISPLAY}..."

if command -v tigervncserver >/dev/null 2>&1; then
    if tigervncserver -list 2>/dev/null |
        grep -Fq ":${VNC_DISPLAY}"; then

        tigervncserver -kill ":${VNC_DISPLAY}"
        log "TigerVNC display stopped."
    else
        log "TigerVNC display was not running."
    fi
else
    log "TigerVNC server command not found; nothing to stop."
fi

log "Desktop shutdown completed."
