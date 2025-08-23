#!/bin/bash
# scripts/generate-secret.sh

SECRET_DIR=${1:-./secrets}
SECRET_FILE="$SECRET_DIR/runtime-secret.txt"

mkdir -p "$SECRET_DIR"

# Генерируем случайный секрет (32 символа)
openssl rand -hex 16 > "$SECRET_FILE"

echo "✅ Runtime secret generated at $SECRET_FILE"
chmod 400 "$SECRET_FILE"
