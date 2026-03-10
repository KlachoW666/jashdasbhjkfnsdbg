#!/bin/bash
# Пересборка better-sqlite3 под текущую версию Node.js.
# Ошибка: NODE_MODULE_VERSION 115 vs 127 — модуль собран под другую Node.
# Запуск на сервере от root: ./fix-better-sqlite3.sh

set -e
APP_DIR="${APP_DIR:-/var/www/miniapp}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите от root: sudo ./fix-better-sqlite3.sh"
  exit 1
fi

echo "Текущая Node: $(node -v)"
echo "Пересборка нативных модулей в backend..."
cd "$APP_DIR/promt/backend"
npm rebuild
echo "Перезапуск zyphex-api..."
pm2 restart zyphex-api
pm2 save
sleep 2
echo ""
if curl -sf --max-time 3 "http://127.0.0.1:3001/api/health" >/dev/null 2>&1; then
  echo "OK — API отвечает на порту 3001."
else
  echo "API пока не отвечает. Проверьте: pm2 logs zyphex-api --lines 20"
  exit 1
fi
