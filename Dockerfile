FROM node:22-alpine AS base

FROM base AS builder
WORKDIR /app
COPY package.json ./package.json
COPY package-lock.json ./package-lock.json
RUN npm ci
# Копируем секрет на стадии сборки (доступен только во время build)
RUN --mount=type=secret,id=build_secret,dst=/run/secrets/build_secret \
    echo "Build secret was processed during image build" && \
    echo "Secret length: $(cat /run/secrets/build_secret | wc -c)" && \
    # mkdir -p /tmp/secrets && \
    cat /run/secrets/build_secret > /build-secret-from-file.txt
# Можно также передать секрет как переменную среды на стадии сборки (опционально)
# RUN --mount=type=secret,id=build_secret \
#     echo "Build secret was processed during image build" && \
#     echo "Secret length: $(cat /run/secrets/build_secret | wc -c)"
# Сохранение секрета на стадии сборки
# RUN --mount=type=secret,id=build_secret,dst=/run/secrets/build_secret \
#     mkdir -p /build-secrets && \
#     cat /run/secrets/build_secret > /build-secrets/build_secret.txt && \
#     chmod 400 /build-secrets/build_secret.txt

FROM base AS runner

ARG APP_VERSION=unknown
ENV APP_VERSION=${APP_VERSION}
LABEL org.opencontainers.image.title="Docker GHCR publish app"
LABEL org.opencontainers.image.description="Test app for Docker Compose secrets (build & runtime)"
LABEL org.opencontainers.image.version=${APP_VERSION}
LABEL org.opencontainers.image.source="https://github.com/Reki7/docker_publish"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Home Inc"
LABEL org.opencontainers.image.url="https://ghcr.io/Reki7/docker_publish"

WORKDIR /app
COPY src/index.js .

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /build-secret-from-file.txt ./build_secret
# RUN --mount=type=secret,id=build_secret,dst=/run/secrets/build_secret \
#     echo "Build secret was processed during image build" && \
#     echo "Secret length: $(cat /run/secrets/build_secret | wc -c)" && \
#     cat /run/secrets/build_secret > ./build_secret

CMD ["node", "index.js"]
