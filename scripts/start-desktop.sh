
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

require_vnc_password

mkdir -p "$HOME/.vnc"
mkdir -p "$HOME/.logs"

# Configure TigerVNC password
printf '%s\n' "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"

# Start the XFCE desktop with TigerVNC
if ! vncserver -list 2>/dev/null | grep -q ":${VNC_DISPLAY}"; then
    vncserver ":${VNC_DISPLAY}" \
        -rfbport "$VNC_PORT" \
        -localhost yes \
        -geometry "${VNC_GEOMETRY:-1280x800}" \
        -depth "${VNC_DEPTH:-24}" \
        -SecurityTypes VncAuth
fi

# Start noVNC WebSocket proxy
if ! pgrep -af "[w]ebsockify.*${NOVNC_PORT}" >/dev/null; then
    nohup websockify \
        --web=/usr/share/novnc \
        "127.0.0.1:${NOVNC_PORT}" \
        "127.0.0.1:${VNC_PORT}" \
        > "$HOME/.logs/novnc.log" 2>&1 &
fi

echo "TigerVNC desktop started."
echo "VNC port: ${VNC_PORT}"
echo "noVNC port: ${NOVNC_PORT}"
