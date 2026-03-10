#!/bin/bash
# Быстрое исправление ERR_SSL_VERSION_OR_CIPHER_MISMATCH (Telegram не открывает zyphex.ru).
# Запускать на сервере из каталога с репозиторием: sudo ./fix-ssl-nginx.sh
# Полностью переприменяет конфиг Nginx из install.sh (без пересборки приложения).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
  echo "Run from repo root (where install.sh is)."
  exit 1
fi
echo "Re-applying Nginx config (SSL protocols and ciphers for Telegram)..."
cd "$SCRIPT_DIR"
./install.sh
