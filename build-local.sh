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

# === Генерация меток ===
# Время сборки (RFC 3339)
CREATED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Git revision (хеш коммита) или unknown
if git rev-parse --git-dir > /dev/null 2>&1; then
  REVISION=$(git rev-parse HEAD)
  echo "🔖 Git revision: $REVISION"
else
  REVISION="unknown"
  echo "🔖 Git revision: not a repo → 'unknown'"
fi

# Теги
TAG_VERSION="$IMAGE_NAME:$VERSION"
TAG_LATEST="$IMAGE_NAME:latest"

echo "🎯 Собираем образ:"
echo "   - $TAG_VERSION"
echo "   - $TAG_LATEST"
echo "   - Метки:"
echo "     • org.opencontainers.image.created=$CREATED"
echo "     • org.opencontainers.image.revision=$REVISION"

# Включаем BuildKit
export DOCKER_BUILDKIT=1

# Сборка с секретом
docker build \
  --progress=plain \
  --build-arg APP_VERSION="$VERSION" \
  --secret id=build_secret,src="$BUILD_SECRET_FILE" \
  --tag "$TAG_VERSION" \
  --tag "$TAG_LATEST" \
  --label "org.opencontainers.image.created=$CREATED" \
  --label "org.opencontainers.image.revision=$REVISION" \
  # --label "org.opencontainers.image.version=$VERSION" \
  # --label "org.opencontainers.image.title=My Node App" \
  # --label "org.opencontainers.image.description=Test app for Docker secrets and GHCR publishing" \
  # --label "org.opencontainers.image.source=https://github.com/${GITHUB_USER}/my-node-app" \
  # --label "org.opencontainers.image.licenses=MIT" \
  # --label "org.opencontainers.image.vendor=Your Name" \  
  .

echo "✅ Сборка завершена!"
echo "   Доступные образы:"
echo "   - $TAG_VERSION"
echo "   - $TAG_LATEST"

# Показать метки (опционально)
echo "🔍 Проверка меток:"
docker inspect "$TAG_VERSION" --format '{{ json .Config.Labels }}' | jq .

# Опционально: показать последние образы
# docker image ls "ghcr.io/${GITHUB_USER}/my-node-app" | head -5


# echo "📤 Публикуем на GHCR..."
# Перед запуском: export CR_PAT=your_github_personal_access_token

# echo "Логин в ghcr.io..."
# echo "$CR_PAT" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin

# echo "Пушим образы..."
# docker push "$TAG_VERSION"
# docker push "$TAG_LATEST"

# echo "✅ Образы опубликованы на GHCR"