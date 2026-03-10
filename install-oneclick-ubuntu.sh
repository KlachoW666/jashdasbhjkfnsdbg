#!/bin/bash
# Установка Zyphex Auto в 1 клик на Ubuntu 24.04 (или Debian)
# Запуск: curl -sL https://raw.githubusercontent.com/KlachoW666/jashdasbhjkfnsdbg/main/install-oneclick-ubuntu.sh | sudo bash
# С своим доменом: curl -sL ... | sudo DOMAIN=your-domain.ru SERVER_IP=1.2.3.4 bash

set -e
REPO="https://github.com/KlachoW666/jashdasbhjkfnsdbg.git"
BRANCH="main"
INSTALL_URL="https://raw.githubusercontent.com/KlachoW666/jashdasbhjkfnsdbg/main/install.sh"

echo "Zyphex Auto — установка в 1 клик (Ubuntu 24.04 / Debian)"
echo ""

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите от root или через sudo: sudo bash $0"
  exit 1
fi

export DOMAIN="${DOMAIN:-zyphex.ru}"
export SERVER_IP="${SERVER_IP:-188.127.230.83}"
export BACKEND_PORT="${BACKEND_PORT:-3001}"

echo "Домен: $DOMAIN"
echo "IP сервера: $SERVER_IP"
echo "Скачиваю install.sh и запускаю..."
echo ""

curl -sL -o /tmp/zyphex-install.sh "$INSTALL_URL"
chmod +x /tmp/zyphex-install.sh
exec /tmp/zyphex-install.sh
