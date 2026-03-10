#!/bin/bash
# Удаление файла базы данных Zyphex (все пользователи и данные будут потеряны).
# Перед удалением останавливаем backend, чтобы БД не была занята.
# Запуск на сервере: sudo ./delete-database.sh

set -e
APP_DIR="${APP_DIR:-/var/www/miniapp}"
BACKEND_DIR="$APP_DIR/promt/backend"
DB_PATH="${DB_PATH:-$BACKEND_DIR/data/zyphex.db}"

echo "Будет удалён файл: $DB_PATH"
read -p "Вы уверены? Все пользователи и данные будут потеряны. (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[yY]$ ]]; then
  echo "Отменено."
  exit 0
fi

echo "Останавливаем zyphex-api..."
pm2 stop zyphex-api 2>/dev/null || true
sleep 1

if [ -f "$DB_PATH" ]; then
  rm -f "$DB_PATH"
  echo "База данных удалена: $DB_PATH"
else
  echo "Файл не найден: $DB_PATH (уже удалён или другой путь). Укажите DB_PATH при необходимости."
fi

echo "Запускаем backend снова (создаст новую пустую БД при старте)..."
cd "$BACKEND_DIR"
PORT=3001 pm2 start server.js --name zyphex-api --cwd "$BACKEND_DIR" \
  --max-restarts 999999 --restart-delay 3000 --exp-backoff-restart-delay 100 2>/dev/null || pm2 restart zyphex-api
pm2 save
echo "Готово."
