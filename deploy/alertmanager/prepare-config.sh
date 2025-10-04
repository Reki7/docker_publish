#!/bin/sh
# alertmanager/prepare-config.sh

set -eu

CONFIG_TPL="/etc/alertmanager/alertmanager.tmpl.yml"
CONFIG_OUT="/etc/alertmanager/alertmanager.yml"

echo "🔧 Генерация конфига из шаблона..."

if [ -z "${ALERTMANAGER_TELEGRAM_TOKEN:-}" ]; then
  echo "❌ ALERTMANAGER_TELEGRAM_TOKEN не задан" >&2
  exit 1
fi

if [ -z "${ALERTMANAGER_CHAT_ID:-}" ]; then
  echo "❌ ALERTMANAGER_CHAT_ID не задан" >&2
  exit 1
fi

# Подстановка
sed \
  -e "s|{{ .TOKEN }}|${ALERTMANAGER_TELEGRAM_TOKEN}|g" \
  -e "s|{{ .CHAT_ID }}|${ALERTMANAGER_CHAT_ID}|g" \
  "$CONFIG_TPL" > "$CONFIG_OUT"

echo "✅ Конфиг сгенерирован: $CONFIG_OUT"

# Проверка синтаксиса конфига (опционально)
echo "🔧 Проверка конфига Alertmanager..."
if /bin/alertmanager --config.validate-files --config.file="$CONFIG_OUT" > /dev/null 2>&1; then
  echo "✅ Конфиг корректен"
else
  echo "❌ Ошибка: конфиг Alertmanager некорректен" >&2
  exit 1
fi

echo "✅ Конфиг готов"

echo "🚀 Запуск Alertmanager..."
exec /bin/alertmanager --config.file="$CONFIG_OUT" "$@"
