#!/bin/bash
# build-local.sh — локальная сборка образа с секретами и тегами

set -euo pipefail

echo "🛠️  Запуск локальной сборки Docker-образа..."

# === Настройки ===
GITHUB_USER="${GITHUB_USER:-reki7}"  # Замени или передай через env
IMAGE_NAME="ghcr.io/${GITHUB_USER}/docker_publish"

# Проверка наличия package.json
if [[ ! -f package.json ]]; then
  echo "❌ Файл package.json не найден"
  exit 1
fi

# Извлечение версии из package.json
if ! command -v jq &> /dev/null; then
  echo "❌ Требуется утилита 'jq'. Установите: apt install jq (или brew install jq)"
  exit 1
fi

VERSION=$(jq -r .version package.json)
if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
  echo "❌ Не удалось извлечь версию из package.json"
  exit 1
fi

echo "📦 Версия из package.json: $VERSION"

# Проверка директории с секретами
BUILD_SECRET_FILE="./build-secrets/build-secret.txt"
if [[ ! -f "$BUILD_SECRET_FILE" ]]; then
  echo "❌ Секрет для сборки не найден: $BUILD_SECRET_FILE"
  echo "Создайте файл с содержимым:"
  echo "  mkdir -p build-secrets && echo 'my-super-secret' > build-secrets/build-secret.txt"
  exit 1
fi

# Теги
TAG_VERSION="$IMAGE_NAME:$VERSION"
TAG_LATEST="$IMAGE_NAME:latest"

echo "🎯 Собираем образ:"
echo "   - $TAG_VERSION"
echo "   - $TAG_LATEST"

# Включаем BuildKit
export DOCKER_BUILDKIT=1

# Сборка с секретом
docker build \
  --progress=plain \
  --build-arg APP_VERSION="$VERSION" \
  --secret id=build_secret,src="$BUILD_SECRET_FILE" \
  --tag "$TAG_VERSION" \
  --tag "$TAG_LATEST" \
  .

echo "✅ Сборка завершена!"
echo "   Доступные образы:"
echo "   - $TAG_VERSION"
echo "   - $TAG_LATEST"

# Опционально: показать последние образы
docker image ls "ghcr.io/${GITHUB_USER}/my-node-app" | head -5
