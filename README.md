# Codespaces Cloud Desktop — TigerVNC edition

Adapted from **MSFTLabs/msftlabs-codespace-cloudpc** (MIT licensed).

This version is deliberately smaller and focused on an XFCE desktop for a GitHub Codespace. It uses TigerVNC for the desktop, noVNC for browser access, and Codespaces lifecycle hooks to start the desktop again when the Codespace container starts.

## Port layout

| Service | Port | Purpose |
|---|---:|---|
| TigerVNC | `5900` | Native VNC protocol, for Android/desktop VNC Viewer through a secure tunnel |
| noVNC | `6080` | Browser-based VNC client |

TigerVNC uses display `:1`, with its TCP port explicitly set to `5900`. It listens on loopback only (`127.0.0.1`) so the raw VNC service is not exposed directly to the internet.

## Before creating the Codespace

1. Put this project in your GitHub repository.
2. In the repository's **Settings → Secrets and variables → Codespaces**, create a secret named exactly `VNC_PASSWORD`.
3. Use a password whose first 8 characters are unique and strong. Traditional VNC password authentication uses at most 8 characters.
4. Create a Codespace and wait for the image to build.

**Never put the VNC password in `config/desktop.env`, source code, or a committed file.** The setup script deliberately fails if the Codespaces secret is unavailable.

## Browser access

1. Open the Codespace's **Ports** tab.
2. Manually add port `6080`.
3. Keep it **Private**.
4. Open its forwarded address and append `/vnc.html`.
5. Enter your VNC password.

Port `6080` is intentionally not auto-forwarded by `.devcontainer/devcontainer.json`.

## Android VNC Viewer access (native VNC)

A Codespaces forwarded web URL is an HTTP(S) proxy, not a raw VNC socket. Do not enter the `app.github.dev` URL into VNC Viewer.

For native VNC Viewer access, create a TCP tunnel from the Android phone using Termux and GitHub CLI:

1. Install Termux from a trusted source and install GitHub CLI in Termux (for example, `pkg install gh` if available for your Termux repository).
2. Authenticate GitHub CLI: `gh auth login`.
3. Find your Codespace name in GitHub → Codespaces.
4. In Termux, run:

   ```bash
   gh codespace ports forward 5900:5900 -c YOUR_CODESPACE_NAME
   ```

5. Leave that command running while using VNC Viewer.
6. In VNC Viewer, create a connection to:
   - Address: `127.0.0.1`
   - Port: `5900`
7. Enter the VNC password.

The tunnel is local to the phone. Keep the Termux session alive while connected. If the Codespace sleeps or stops, restart the Codespace and run the tunnel command again.

**Security:** do not make port `5900` public. TigerVNC's traditional VNC password authentication does not encrypt the desktop session by itself; the SSH-like Codespaces tunnel protects the connection in transit.

## Automatic startup

- `.devcontainer/post-create.sh` configures the VNC password and XFCE startup script after creation/rebuild.
- `postStartCommand` runs `scripts/start-desktop.sh` whenever the container starts.
- After an ordinary Codespaces sleep, reopen the same Codespace. The lifecycle hook starts the desktop again. You do not need to rebuild it just because it slept.

## Included software

- XFCE desktop and terminal
- Thunar file manager, Mousepad text editor
- TigerVNC server
- noVNC and websockify

Azure CLI, PowerShell, Terraform, Bicep, Ansible, Edge, VS Code desktop and their extensions have been removed to reduce build size and build time.

## Multilogin note

This package does **not** install Multilogin or relocate its profile directory. That should be done only after confirming the current official Linux installer and the actual profile/data directory used by the installed Multilogin version. Do not assume that `/data` or a generic `.config` folder is the profile directory.

For persistent browser profiles, the final Multilogin profile path must be mapped into a directory under `/workspaces` and verified before relying on it.

## Configuration

Edit `config/desktop.env` for display, ports, resolution and colour depth. Do not add credentials there.

Default values:
- `VNC_DISPLAY=1`
- `VNC_PORT=5900`
- `NOVNC_PORT=6080`
- `VNC_RESOLUTION=1440x900`
- `VNC_COL_DEPTH=24`
- `NOVNC_TLS=false` (Codespaces browser forwarding already uses HTTPS)

## Manual commands

```bash
bash scripts/setup-desktop.sh --config-only
bash scripts/start-desktop.sh
bash scripts/stop-desktop.sh
```

## Attribution and licence

This project adapts the MIT-licensed `MSFTLabs/msftlabs-codespace-cloudpc` project. The original licence is retained in `LICENSE`.
