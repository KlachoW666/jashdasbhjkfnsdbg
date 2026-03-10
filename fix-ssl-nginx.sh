#!/bin/bash
# Исправление NET::ERR_CERT_AUTHORITY_INVALID / «Подключение не защищено» для zyphex.ru
# Получает сертификат Let's Encrypt и переприменяет Nginx (подходит для Debian 13 / Ubuntu 24.04).
# Запуск на сервере от root (на Debian часто без sudo): ./fix-ssl-nginx.sh
# Либо: cd /var/www/miniapp && ./fix-ssl-nginx.sh

set -e

# Настройки под ваш проект (Debian 13, zyphex.ru)
DOMAIN="${DOMAIN:-zyphex.ru}"
SERVER_IP="${SERVER_IP:-188.127.230.83}"
CERTBOT_EMAIL="${CERTBOT_EMAIL:-admin@zyphex.ru}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите скрипт от root: sudo ./fix-ssl-nginx.sh или (под root) ./fix-ssl-nginx.sh"
  exit 1
fi

if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
  echo "Запустите из корня репозитория (где лежит install.sh)."
  exit 1
fi

echo "======================================"
echo "  Fix SSL — $DOMAIN (Let's Encrypt + Nginx)"
echo "======================================"
echo "Домен: $DOMAIN"
echo "IP:    $SERVER_IP"
echo ""

# 1. Получить сертификат Let's Encrypt, если его ещё нет
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ] || [ ! -f "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ]; then
  echo "[1/3] Получение сертификата Let's Encrypt для $DOMAIN ..."
  echo "      Убедитесь, что DNS A-запись $DOMAIN указывает на $SERVER_IP."
  if command -v certbot >/dev/null 2>&1; then
    certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos -m "$CERTBOT_EMAIL" || {
      echo "      Ошибка certbot. Проверьте DNS и порты 80/443."
      exit 1
    }
  else
    echo "      Установите certbot: apt-get install -y certbot python3-certbot-nginx"
    exit 1
  fi
else
  echo "[1/3] Сертификат Let's Encrypt уже есть."
fi

# 2. Убрать конфликтующий конфиг certbot (location not allowed here)
echo "[2/3] Удаление конфликтующего конфига Nginx для $DOMAIN ..."
rm -f /etc/nginx/sites-enabled/"$DOMAIN" /etc/nginx/sites-enabled/"$DOMAIN".conf

# 3. Переприменить полный конфиг из install.sh (шифры, /api/, /miniapp/, LE cert)
echo "[3/3] Применение конфига Nginx из install.sh ..."
cd "$SCRIPT_DIR"
export DOMAIN SERVER_IP CERTBOT_EMAIL
./install.sh

echo ""
echo "Готово. Проверьте в браузере: https://$DOMAIN/miniapp/"
echo "В Telegram мини-приложение должно открываться без предупреждения о сертификате."
