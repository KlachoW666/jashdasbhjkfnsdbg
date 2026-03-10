#!/bin/bash
# Перезапуск backend с портом 3001 (если check-server.sh показал «backend не отвечает»).
# Запуск от root: ./restart-backend.sh

set -e
BACKEND_PORT="${BACKEND_PORT:-3001}"
APP_DIR="${APP_DIR:-/var/www/miniapp}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите от root: sudo ./restart-backend.sh"
  exit 1
fi

echo "Перезапуск zyphex-api на порту $BACKEND_PORT..."
pm2 delete zyphex-api 2>/dev/null || true
cd "$APP_DIR/promt/backend"
PORT=$BACKEND_PORT pm2 start server.js --name zyphex-api --cwd "$APP_DIR/promt/backend" \
  --max-restarts 999999 --restart-delay 3000 --exp-backoff-restart-delay 100
pm2 save
echo ""
echo "Проверка: curl -s http://127.0.0.1:$BACKEND_PORT/api/health"
sleep 2
curl -sf "http://127.0.0.1:$BACKEND_PORT/api/health" && echo " — OK" || echo " — не отвечает, смотрите: pm2 logs zyphex-api --lines 20"
