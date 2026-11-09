
#!/usr/bin/env bash
set -Eeuo pipefail

# Find repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load non-secret desktop configuration
CONFIG_FILE="$REPO_ROOT/config/desktop.env"

if [[ -f "$CONFIG_FILE" ]]; then
    set -a
    source "$CONFIG_FILE"
    set +a
fi

# Desktop defaults
VNC_DISPLAY="${VNC_DISPLAY:-1}"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1280x800}"
VNC_DEPTH="${VNC_DEPTH:-24}"

# VNC password must come from the Codespaces secret
VNC_PASSWORD="${VNC_PASSWORD:-}"

require_vnc_password() {
    if [[ -z "$VNC_PASSWORD" ]]; then
        echo "ERROR: VNC_PASSWORD is not set."
        echo "Configure VNC_PASSWORD as a GitHub Codespaces secret."
        exit 1
    fi
}
