# WEVOX Auto — Telegram Mini App

Telegram Web App для авто-трейдинга: пополнение USDT, обмен на WEVOX, рефералы.  
Домен: **https://wevox.ru** (или WEVOX.RU).

## Структура

- **promt/frontend** — Mini App (React + Vite)
- **promt/backend** — API (Node.js, Express, SQLite)
- **promt/landing** — лендинг
- **install.sh** — скрипт установки на Ubuntu 24.04

## Деплой на VPS (Ubuntu 24.04)

1. На сервере выполните (от root или через sudo):
   ```bash
   curl -sL -o install.sh https://raw.githubusercontent.com/KlachoW666/raimeswevo/main/install.sh
   chmod +x install.sh
   sudo ./install.sh
   ```
   Или клонируйте репозиторий и запустите `./install.sh` из корня.

2. Скрипт:
   - Ставит Node.js 20, Nginx, PM2, UFW
   - Клонирует этот репозиторий в `/var/www/miniapp`
   - Собирает frontend, запускает backend (порт 3001)
   - Настраивает Nginx для домена и HTTPS

3. Переменные (при необходимости):
   - `DOMAIN=wevox.ru` — домен (по умолчанию wevox.ru)
   - `SERVER_IP=91.219.151.56` — IP сервера (по умолчанию)
   - `BACKEND_PORT=3001` — порт API

4. В BotFather укажите URL Mini App: **https://wevox.ru/miniapp**

**Важно:** В GitHub у репозитория должна быть ветка **main** (install.sh делает `git pull` / `git reset --hard origin/main`). Если используете другую ветку, измените в install.sh `origin/main` на нужную.

## Локальная разработка

- **Backend:** `cd promt/backend && npm install && npm run dev` (порт 3001 по умолчанию)
- **Frontend:** `cd promt/frontend && npm install && npm run dev` (Vite, порт 5173)
- **Landing:** откройте `promt/landing/index.html` в браузере или раздайте через любой HTTP-сервер
