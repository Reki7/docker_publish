FROM node:22-alpine AS base

FROM base AS builder

COPY package.json /tmp/package.json

ARG APP_VERSION=unknown
ENV APP_VERSION=${APP_VERSION}

LABEL org.opencontainers.image.title="Docker GHCR publish app"
LABEL org.opencontainers.image.description="Test app for Docker Compose secrets (build & runtime)"
LABEL org.opencontainers.image.version=${APP_VERSION}
LABEL org.opencontainers.image.source="https://github.com/Reki7/docker_publish"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Home Inc"
LABEL org.opencontainers.image.url="https://ghcr.io/Reki7/docker_publish"

RUN --mount=type=secret,id=build_secret,dst=/run/secrets/build_secret \
    mkdir -p /build-secrets && \
    cat /run/secrets/build_secret > /build-secrets/build_secret.txt && \
    chmod 400 /build-secrets/build_secret.txt

FROM base AS runner

ARG APP_VERSION=unknown
LABEL org.opencontainers.image.title="Docker GHCR publish app"
LABEL org.opencontainers.image.description="Test app for Docker Compose secrets (build & runtime)"
LABEL org.opencontainers.image.version=${APP_VERSION}
LABEL org.opencontainers.image.source="https://github.com/Reki7/docker_publish"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Home Inc"
LABEL org.opencontainers.image.url="https://ghcr.io/Reki7/docker_publish"

WORKDIR /app
COPY src/index.js .

COPY --from=builder /build-secrets/build_secret.txt /run/secrets/build_secret

CMD ["node", "index.js"]
