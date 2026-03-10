#!/bin/bash
# Диагностика «Сервер недоступен» — запустить на VPS (Debian/Ubuntu) от root.
# Проверяет backend, Nginx и доступность https://zyphex.ru/api/health

set -e
DOMAIN="${DOMAIN:-zyphex.ru}"
BACKEND_PORT="${BACKEND_PORT:-3001}"
FAIL=0

echo "======================================"
echo "  Проверка сервера Zyphex ($DOMAIN)"
echo "======================================"
echo ""

echo "[1] Backend (PM2)..."
if pm2 describe zyphex-api >/dev/null 2>&1; then
  echo "    OK — zyphex-api в PM2"
else
  echo "    FAIL — процесс zyphex-api не найден. Запустите: cd /var/www/miniapp/promt/backend && PORT=$BACKEND_PORT pm2 start server.js --name zyphex-api && pm2 save"
  FAIL=1
fi

echo "[2] API на localhost:$BACKEND_PORT..."
if curl -sf --max-time 2 "http://127.0.0.1:$BACKEND_PORT/api/health" >/dev/null 2>&1; then
  echo "    OK — backend отвечает на порту $BACKEND_PORT"
else
  if curl -sf --max-time 2 "http://127.0.0.1:3000/api/health" >/dev/null 2>&1; then
    echo "    ВНИМАНИЕ — backend отвечает на порту 3000, а Nginx ждёт $BACKEND_PORT. Перезапустите с PORT=3001: pm2 delete zyphex-api; cd /var/www/miniapp/promt/backend && PORT=3001 pm2 start server.js --name zyphex-api --cwd /var/www/miniapp/promt/backend && pm2 save"
    FAIL=1
  else
    echo "    FAIL — backend не отвечает. Перезапустите: cd /var/www/miniapp/promt/backend && PORT=3001 pm2 delete zyphex-api 2>/dev/null; PORT=3001 pm2 start server.js --name zyphex-api --cwd /var/www/miniapp/promt/backend && pm2 save"
    echo "    Логи: pm2 logs zyphex-api --lines 30"
    FAIL=1
  fi
fi

echo "[3] Nginx..."
if systemctl is-active --quiet nginx 2>/dev/null; then
  echo "    OK — Nginx запущен"
else
  echo "    FAIL — Nginx не запущен. Запустите: systemctl start nginx"
  FAIL=1
fi

if [ -f /etc/nginx/sites-enabled/miniapp ]; then
  echo "    OK — конфиг miniapp включён"
else
  echo "    FAIL — нет /etc/nginx/sites-enabled/miniapp. Запустите: ./install.sh или ln -sf /etc/nginx/sites-available/miniapp /etc/nginx/sites-enabled/"
  FAIL=1
fi

if [ -f "/etc/nginx/sites-enabled/$DOMAIN" ] || [ -f "/etc/nginx/sites-enabled/$DOMAIN.conf" ]; then
  echo "    ВНИМАНИЕ — есть конфиг $DOMAIN в sites-enabled (может конфликтовать). Удалите: rm -f /etc/nginx/sites-enabled/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN.conf"
fi

echo "[4] HTTPS $DOMAIN/api/health (с сервера)..."
if curl -sf --max-time 5 "https://$DOMAIN/api/health" 2>/dev/null | grep -q '"ok"'; then
  echo "    OK — API доступен по HTTPS"
else
  echo "    FAIL или предупреждение SSL — запрос не прошёл. Проверьте сертификат: certbot certificates. Затем: ./fix-ssl-nginx.sh"
  FAIL=1
fi

echo ""
echo "======================================"
if [ "$FAIL" -eq 0 ]; then
  echo "  Всё в порядке на сервере."
  echo "  Если в Telegram всё ещё «Сервер недоступен», пересоберите frontend с доменом:"
  echo "  cd /var/www/miniapp/promt/frontend && VITE_APP_URL=https://$DOMAIN npm run build"
else
  echo "  Есть проблемы. Исправьте пункты выше и снова запустите: ./check-server.sh"
fi
echo "======================================"
