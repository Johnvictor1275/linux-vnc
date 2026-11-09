#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

log "Stopping noVNC on port ${NOVNC_PORT}..."
pkill -f "[w]ebsockify.*${NOVNC_PORT}" >/dev/null 2>&1 || true

log "Stopping TigerVNC display :${VNC_DISPLAY}..."
vncserver -kill ":${VNC_DISPLAY}" >/dev/null 2>&1 || true

log "CloudPC desktop stopped."
