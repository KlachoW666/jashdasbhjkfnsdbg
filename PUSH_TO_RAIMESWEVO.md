# Как залить этот код в репозиторий raimeswevo

Чтобы **удалить всё** из [github.com/KlachoW666/raimeswevo](https://github.com/KlachoW666/raimeswevo) и **заменить** содержимое на этот проект (чтобы `install.sh` клонировал именно его), сделайте следующее.

## 1. Добавьте удалённый репозиторий raimeswevo

В папке проекта (MiniApps) выполните в терминале:

```bash
cd c:\MiniApps

# Если origin уже указывает на другой репозиторий — добавьте raimeswevo как отдельный remote:
git remote add raimeswevo https://github.com/KlachoW666/raimeswevo.git

# Если origin уже raimeswevo или вы хотите сделать raimeswevo основным:
# git remote set-url origin https://github.com/KlachoW666/raimeswevo.git
```

## 2. Убедитесь, что ветка называется main

Скрипт `install.sh` использует ветку `main`. Если у вас ветка называется иначе (например `master`):

```bash
git branch -M main
```

## 3. Залить код в raimeswevo (полная замена)

Заливка **перезапишет** текущее содержимое raimeswevo этим проектом.

```bash
# Закоммитьте все изменения, если ещё не закоммичены:
git add -A
git status
git commit -m "WEVOX: full project for install.sh (wevox.ru, Ubuntu 24.04)"

# Отправка в raimeswevo (замена истории репозитория):
git push raimeswevo main --force
```

Если вы сделали `raimeswevo` под именем `origin`:

```bash
git push origin main --force
```

**Важно:** `--force` заменяет историю в репозитории raimeswevo. Всё, что было там раньше (backend/, frontend/ в корне, старый README и т.д.), будет заменено структурой этого проекта (promt/, install.sh, новый README).

## 4. Проверка на GitHub

1. Откройте https://github.com/KlachoW666/raimeswevo  
2. Убедитесь, что в корне есть: `install.sh`, `promt/`, `README.md`, `.gitignore`  
3. В настройках репозитория (Settings → General) установите ветку по умолчанию **main**, если она ещё не main.

После этого на любом сервере можно запускать:

```bash
sudo ./install.sh
```

(скрипт клонирует `https://github.com/KlachoW666/raimeswevo.git` в `/var/www/miniapp` и развернёт WEVOX).
