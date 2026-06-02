#!/usr/bin/env bash
# deploy-freellm.sh — Deploy FreeLLMAPI on a Node 20+ host (no Docker required).
# Tested on OpenClaw 2026.3.12 host (d8d0969fe39e98).

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/root/freellmapi}"
PORT="${PORT:-3001}"

if ! command -v node >/dev/null 2>&1; then
  echo "❌ node not found. Install Node 20+ first." >&2
  exit 1
fi

NODE_MAJOR=$(node -p 'process.versions.node.split(".")[0]')
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "❌ Node 20+ required (found $(node --version))." >&2
  exit 1
fi

if [ ! -d "$INSTALL_DIR" ]; then
  echo "→ Cloning freellmapi into $INSTALL_DIR"
  git clone https://github.com/tashfeenahmed/freellmapi.git "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

if [ ! -f .env ]; then
  echo "→ Generating .env with random ENCRYPTION_KEY"
  ENCRYPTION_KEY="$(node -e 'console.log(require("crypto").randomBytes(32).toString("hex"))')"
  printf "ENCRYPTION_KEY=%s\nPORT=%s\n" "$ENCRYPTION_KEY" "$PORT" > .env
fi

echo "→ Installing deps"
npm install

echo "→ Building"
npm run build

echo "→ Starting FreeLLMAPI on port $PORT"
echo "  Logs will print to stdout. Use systemd/pm2/supervisord to supervise."
echo ""
node server/dist/index.js
