#!/bin/bash
# Удаление лишних файлов из /root/ (остатки WEVOX, старые скрипты).
# Запуск на сервере от root: sudo ./cleanup-root.sh
# Репозиторий и приложение должны быть в /var/www/miniapp.

set -e
ROOT_HOME="${ROOT_HOME:-/root}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите от root: sudo ./cleanup-root.sh"
  exit 1
fi

cd "$ROOT_HOME" || exit 1

REMOVED=()
for name in wevo install.sh miniapp-nginx-example.conf start.sh; do
  if [ -e "$name" ]; then
    rm -rf "$name"
    REMOVED+=("$name")
  fi
done
# Файлы вида openclaw-* (старые ключи/конфиги)
for f in openclaw-* 2>/dev/null; do
  [ -e "$f" ] && rm -rf "$f" && REMOVED+=("$f") || true
done

if [ ${#REMOVED[@]} -eq 0 ]; then
  echo "В $ROOT_HOME не найдено указанных файлов/папок для удаления."
else
  echo "Удалено: ${REMOVED[*]}"
fi
echo "Готово. Актуальные скрипты — в /var/www/miniapp (install.sh, check-server.sh, fix-ssl-nginx.sh, restart-backend.sh)."
