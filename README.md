# Zyphex Auto — Telegram Mini App

Telegram Web App для авто-трейдинга: пополнение USDT, обмен на ZYPHEX, рефералы.  
Домен: **https://zyphex.ru** (или ZYPHEX.RU).

## Структура

- **promt/frontend** — Mini App (React + Vite)
- **promt/backend** — API (Node.js, Express, SQLite)
- **promt/landing** — лендинг
- **install.sh** — скрипт установки на Debian 13 / Ubuntu 24.04
- **install-oneclick-ubuntu.sh** — установка в 1 клик (скачивает и запускает install.sh)

## Установка в 1 клик (Ubuntu 24.04)

На чистом VPS с **Ubuntu 24.04** под root выполните одну команду:

```bash
curl -sL https://raw.githubusercontent.com/KlachoW666/jashdasbhjkfnsdbg/main/install-oneclick-ubuntu.sh | sudo bash
```

Скрипт сам скачает `install.sh`, подставит домен **zyphex.ru** и IP **188.127.230.83**, установит Node.js 20, Nginx, PM2, склонирует репозиторий в `/var/www/miniapp`, соберёт frontend и запустит backend. Свой домен или IP задайте так:

```bash
curl -sL https://raw.githubusercontent.com/KlachoW666/jashdasbhjkfnsdbg/main/install-oneclick-ubuntu.sh | sudo DOMAIN=your-domain.ru SERVER_IP=1.2.3.4 bash
```

---

## Деплой на VPS (Debian 13 / Ubuntu 24.04)

1. Либо в 1 клик (см. выше), либо вручную на сервере (от root или через sudo):
   ```bash
   curl -sL -o install.sh https://raw.githubusercontent.com/KlachoW666/jashdasbhjkfnsdbg/main/install.sh
   chmod +x install.sh
   sudo ./install.sh
   ```
   Или клонируйте репозиторий и запустите `./install.sh` из корня.

2. Скрипт (проверен на **Debian 13** и Ubuntu 24.04):
   - Ставит Node.js 20, Nginx, PM2, UFW
   - Клонирует этот репозиторий в `/var/www/miniapp`
   - Собирает frontend, запускает backend (порт 3001) **через PM2** — приложение всегда включено: перезапуск при падении и автозапуск при перезагрузке сервера
   - Настраивает Nginx для домена и HTTPS

3. Переменные (при необходимости):
   - `DOMAIN=zyphex.ru` — домен (по умолчанию zyphex.ru)
   - `SERVER_IP=188.127.230.83` — IP сервера (по умолчанию)
   - `BACKEND_PORT=3001` — порт API

4. В BotFather укажите URL Mini App: **https://zyphex.ru/miniapp**
   - В Telegram откройте @BotFather → **My Bots** → выберите бота (например @wevoautobot) → **Bot Settings** → **Menu Button** → **Configure menu button** → введите URL: `https://zyphex.ru/miniapp` (без слэша в конце). Без этого при переходе по ссылке вида `t.me/wevoautobot/app?startapp=...` будет ошибка **«Веб-приложение не найдено»**.

**Если при переходе по ссылке пишет «Веб-приложение не найдено»:**
- Проверьте в BotFather, что у бота в **Menu Button** указан именно ваш домен: `https://zyphex.ru/miniapp` (или ваш домен вместо zyphex.ru).
- Откройте в браузере `https://zyphex.ru/miniapp` — должна открываться страница приложения (не 404). Если 404 — пересоберите frontend на сервере (`cd /var/www/miniapp/promt/frontend && npm run build`) и проверьте Nginx.

**Почему «Подключение не защищено» / ERR_SSL_VERSION_OR_CIPHER_MISMATCH — и как пофиксить**

Если в Telegram видите «zyphex.ru использует неподдерживаемый протокол» или «Загрузка…» не проходит — соединение блокируется из‑за SSL. Сделайте **на сервере**:

1. **Сертификат Let's Encrypt** (обязательно; самоподписанный Telegram не принимает):
   ```bash
   sudo certbot --nginx -d zyphex.ru -d www.zyphex.ru --agree-tos -m admin@zyphex.ru
   ```
   DNS для домена должен указывать на IP сервера.

2. **Сразу после certbot снова примените конфиг** (certbot может переписать Nginx и убрать нужные шифры — тогда снова будет ERR_SSL_VERSION_OR_CIPHER_MISMATCH):
   ```bash
   cd /var/www/miniapp && sudo ./install.sh
   ```
   Скрипт перезапишет Nginx с `ssl_protocols TLSv1.2 TLSv1.3` и современными `ssl_ciphers`, перезагрузит Nginx. Приложение и база не пострадают.

3. **Проверка:** откройте в браузере `https://zyphex.ru/miniapp/` — должна загрузиться приложение. Затем откройте то же в Telegram — соединение должно установиться, «Загрузка…» сменится на интерфейс приложения.

Вручную (если не хотите запускать install.sh): в `/etc/nginx/sites-available/miniapp` в каждом блоке `listen 443 ssl` должны быть строки:
- `ssl_protocols TLSv1.2 TLSv1.3;`
- `ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;`
- `ssl_prefer_server_ciphers on;`  
Затем: `sudo nginx -t && sudo systemctl reload nginx`.

**Бот и рассылки:** создайте файл `promt/backend/.env` и добавьте строку:
   ```
   TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
   ```
   (токен из @BotFather). После перезапуска backend (pm2 restart zyphex-api) рассылки из админки будут работать. Если рассылка выдаёт ошибку — в ответе API приходит поле `errorDetail` (например: «bot can't initiate conversation» значит пользователь ещё не нажал /start у бота).

**Команда /start у бота:** чтобы при нажатии /start бот присылал приветствие, нужно один раз настроить webhook (подставьте свой домен и токен):
   ```
   curl "https://api.telegram.org/bot<ВАШ_ТОКЕН>/setWebhook?url=https://zyphex.ru/api/telegram-webhook"
   ```
   Убедитесь, что в Nginx проксируется не только `/api/`, но и именно этот путь; при необходимости добавьте в конфиг location для `/api/telegram-webhook`. После этого при отправке /start бот будет отвечать информацией о приложении.

**Важно:** В репозитории [jashdasbhjkfnsdbg](https://github.com/KlachoW666/jashdasbhjkfnsdbg) используется ветка **main**. install.sh клонирует и обновляет именно её (`origin/main`).

**Backend всегда включён (PM2):** API запускается через PM2 с автоперезапуском при сбое и автозапуском при загрузке сервера. Проверить: `pm2 list`, логи: `pm2 logs zyphex-api`, перезапуск вручную: `pm2 restart zyphex-api`.

**Проверка API после деплоя:** из корня репозитория выполните `cd promt/backend && npm run check-api`. Для продакшена задайте `BASE_URL=https://zyphex.ru` (или ваш домен). При необходимости укажите `USER_ID` и `ADMIN_USER_ID` для проверки эндпоинтов с авторизацией.

**CI / автоматическая проверка:** в репозитории настроен GitHub Actions workflow `.github/workflows/api-check.yml`: при push/PR в `main` поднимается backend, выполняется сценарий проверки (health, zyphex/rate; при заданных `USER_ID`/`ADMIN_USER_ID` — также wallet и users). Скрипт `promt/backend/scripts/check-api.mjs` выходит с кодом 1 при ошибке (удобно для CI). Запуск тех же проверок локально: `cd promt/backend && npm test` (или `npm run check-api`).

## Диагностика: приложение не открывается / «загрузка» / «сервер недоступен»

**Быстрая проверка на сервере:** выполните скрипт диагностики (от root):
```bash
cd /var/www/miniapp && chmod +x check-server.sh && ./check-server.sh
```
Он проверит PM2, backend, Nginx и доступность `https://zyphex.ru/api/health` и подскажет, что исправить.

**Ошибка «NODE_MODULE_VERSION 115 / 127» в логах (better-sqlite3):** модуль собран под другую версию Node. На сервере выполните:
```bash
cd /var/www/miniapp && chmod +x fix-better-sqlite3.sh && ./fix-better-sqlite3.sh
```
Или вручную: `cd /var/www/miniapp/promt/backend && npm rebuild && pm2 restart zyphex-api`. Рекомендуется использовать Node 20 (как в install.sh); если установлен Node 22 — пересборка приведёт модуль в соответствие.

Проверьте по шагам **вручную**:

1. **Backend запущен:** `pm2 list` — должен быть процесс `zyphex-api`. Если нет: `cd /var/www/miniapp/promt/backend && PORT=3001 pm2 start server.js --name zyphex-api` и `pm2 save`.
2. **API отвечает:** `curl -s https://zyphex.ru/api/health` — ответ `{"ok":true}`. Если ошибка или таймаут — проверьте Nginx (location /api/ проксирует на порт 3001) и что backend слушает 3001.
3. **Frontend собран и раздаётся:** `ls /var/www/miniapp/promt/frontend/dist/index.html` и `ls /var/www/miniapp/promt/frontend/dist/assets/` — файлы должны быть. Откройте в браузере `https://zyphex.ru/miniapp/` — должна открыться приложение, не 404. Если 404: `cd /var/www/miniapp/promt/frontend && npm run build`, затем перезагрузите Nginx.
4. **Сборка с явным доменом (если с телефона не грузится):** на сервере пересоберите frontend с переменной окружения: `cd /var/www/miniapp/promt/frontend && VITE_APP_URL=https://zyphex.ru npm run build`. Затем перезапустите Nginx при необходимости.

В Telegram: если видите «Сервер недоступен» — backend не отвечает (шаги 1–2). Если бесконечная «Загрузка…» — не открылся JS или API (шаги 2–4).

## Локальная разработка

- **Backend:** `cd promt/backend && npm install && npm run dev` (порт 3001 по умолчанию)
- **Frontend:** `cd promt/frontend && npm install && npm run dev` (Vite, порт 5173)
- **Landing:** откройте `promt/landing/index.html` в браузере или раздайте через любой HTTP-сервер


