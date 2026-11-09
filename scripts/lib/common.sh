
#!/usr/bin/env bash
set -Eeuo pipefail

# Resolve project directories without overwriting the caller's SCRIPT_DIR.
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLOUDPC_ROOT="$(cd "$COMMON_DIR/../.." && pwd)"

# Load desktop configuration.
CONFIG_FILE="$CLOUDPC_ROOT/config/desktop.env"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Desktop configuration defaults.
DESKTOP_ENV="${DESKTOP_ENV:-xfce}"

VNC_DISPLAY="${VNC_DISPLAY:-1}"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"

# Support both configuration naming conventions.
VNC_GEOMETRY="${VNC_GEOMETRY:-${VNC_RESOLUTION:-1440x900}}"
VNC_DEPTH="${VNC_DEPTH:-${VNC_COL_DEPTH:-24}}"

NOVNC_TLS="${NOVNC_TLS:-false}"

# Never store the VNC password in a configuration file.
VNC_PASSWORD="${VNC_PASSWORD:-}"

# Logging helper.
log() {
    printf '[cloudpc] %s\n' "$*"
}

# Fatal error helper.
die() {
    printf '[cloudpc:error] %s\n' "$*" >&2
    exit 1
}

# Check that a required executable exists.
require_cmd() {
    local command_name

    for command_name in "$@"; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            die "Required command not found: $command_name"
        fi
    done
}

# Validate the Codespaces VNC password.
require_vnc_password() {
    if [[ -z "$VNC_PASSWORD" ]]; then
        die "VNC_PASSWORD is missing. Configure it as a GitHub Codespaces secret."
    fi
}

# Validate desktop configuration.
validate_desktop_config() {
    [[ "$VNC_DISPLAY" =~ ^[0-9]+$ ]] ||
        die "VNC_DISPLAY must be a number."

    [[ "$VNC_PORT" =~ ^[0-9]+$ ]] &&
        (( VNC_PORT >= 1 && VNC_PORT <= 65535 )) ||
        die "Invalid VNC_PORT."

    [[ "$NOVNC_PORT" =~ ^[0-9]+$ ]] &&
        (( NOVNC_PORT >= 1 && NOVNC_PORT <= 65535 )) ||
        die "Invalid NOVNC_PORT."

    [[ "$VNC_PORT" != "$NOVNC_PORT" ]] ||
        die "TigerVNC and noVNC must use different ports."

    [[ "$VNC_GEOMETRY" =~ ^[0-9]+x[0-9]+$ ]] ||
        die "VNC resolution must use WIDTHxHEIGHT format."

    [[ "$VNC_DEPTH" =~ ^[0-9]+$ ]] ||
        die "VNC colour depth must be numeric."

    [[ "$NOVNC_TLS" == "true" || "$NOVNC_TLS" == "false" ]] ||
        die "NOVNC_TLS must be true or false."
}
