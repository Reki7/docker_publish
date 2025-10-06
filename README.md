# Test CI/CD for building and publishing app in Docker image

## Workflow

1. Серверный билд срабатывает при пуше тэга с Semantic Versioning ("v[0-9]+.[0-9]+.[0-9]+")
2. Из тэга извлекается версия релиза (отбрасывается начальный символ 'v')
3. Если версия определена успешно, то запускается сборка образа (добавить условие выхода при необнаружении версии?)

Для версий вида "v1.2.3-pre" воркфлоу не должно срабатывать

## Manually add tag and push

```sh
git add .

git commit -m "Version 1.5.2"

git push

git tag v1.5.2   # Lightweight tag = push commit only if it doesn't exist on the remote

# git -a v1.5.2 -m "Version 1.5.2"

git push origin --tags

```
