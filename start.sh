#!/bin/bash
# Start/update Mini App (Zyphex). Run from /root: ./start.sh
# First-time setup: run install.sh once.

set -e

APP_DIR="/var/www/miniapp"
REPO_URL="https://github.com/KlachoW666/afdsghjklsgdhy65.git"
# Port for Mini App API (3001 to avoid conflict with other app on 3000)
BACKEND_PORT="${BACKEND_PORT:-3001}"

echo "======================================"
echo "    Mini App — start/update           "
echo "======================================"

# Check app directory
if [ ! -d "$APP_DIR" ]; then
    echo "Error: $APP_DIR not found. Run install.sh first (full setup)."
    exit 1
fi

# 1. Update from git
echo "[1/4] Updating from git..."
cd "$APP_DIR"
if [ -d ".git" ]; then
    git fetch origin
    git reset --hard origin/main
    echo "Repo updated."
else
    echo "Not a git repo, cloning..."
    if [ -n "$(ls -A $APP_DIR 2>/dev/null)" ]; then
        echo "Error: $APP_DIR exists but is not a git repo. Run install.sh or clean the directory."
        exit 1
    fi
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

# 2. Frontend
echo "[2/4] Building frontend..."
cd "$APP_DIR/promt/frontend"
npm install
npm run build
echo "Frontend built."

# 3. Backend + pm2 (always start with correct cwd so DB path and imports resolve)
echo "[3/4] Backend (zyphex-api)..."
cd "$APP_DIR/promt/backend"
npm install
BACKEND_DIR="$APP_DIR/promt/backend"
if pm2 describe zyphex-api >/dev/null 2>&1; then
    pm2 delete zyphex-api 2>/dev/null || true
fi
PORT=$BACKEND_PORT pm2 start server.js --name zyphex-api --cwd "$BACKEND_DIR"
echo "Backend started on port $BACKEND_PORT (cwd=$BACKEND_DIR)."
pm2 save 2>/dev/null || true
sleep 2
if curl -sf --max-time 5 "http://127.0.0.1:$BACKEND_PORT/api/health" >/dev/null 2>&1; then
    echo "  API health check OK (port $BACKEND_PORT)."
else
    echo "  WARNING: API health check failed. Run: pm2 logs zyphex-api"
fi

# 4. Nginx (ensure proxy points to our backend port)
echo "[4/4] Nginx..."
NGINX_CONF="/etc/nginx/sites-available/miniapp"
if [ -f "$NGINX_CONF" ]; then
    sed -i "s|proxy_pass http://127.0.0.1:[0-9]*;|proxy_pass http://127.0.0.1:${BACKEND_PORT};|" "$NGINX_CONF"
fi
if command -v nginx >/dev/null 2>&1; then
    nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || systemctl start nginx 2>/dev/null || true
    echo "Nginx reloaded/started."
else
    echo "Nginx not installed (optional if using install.sh)."
fi

echo ""
echo "======================================"
echo "    Done. App should be running.      "
echo "======================================"
echo "  Backend:  pm2 list && pm2 logs zyphex-api (port $BACKEND_PORT)"
echo "  API test: curl -s http://127.0.0.1:$BACKEND_PORT/api/zyphex/rate"
echo "======================================"
