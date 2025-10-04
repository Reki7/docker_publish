# Создаём временный файл с секретом
echo "This is my runtime secret!" > /tmp/runtime-secret.txt

# Запуск
docker run --rm \
  --env RUNTIME_SECRET=$(cat /tmp/runtime-secret.txt) \
  --mount type=bind,source=/tmp/runtime-secret.txt,target=/run/secrets/runtime_secret,readonly \
  ghcr.io/your-username/my-node-app:1.0.0





# Экспорт переменной для использования BuildKit
export DOCKER_BUILDKIT=1

# Запуск через docker compose
docker compose up --build
