#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

if [[ -z "${VNC_PASSWORD:-}" ]]; then
  echo "[cloudpc:error] Codespaces secret VNC_PASSWORD is missing." >&2
  echo "Add it under Repository Settings > Secrets and variables > Codespaces, then recreate/rebuild the Codespace." >&2
  exit 1
fi

bash scripts/setup-desktop.sh --config-only
echo "[cloudpc] Desktop configured. It will start automatically when the container starts."
