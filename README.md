# Test CI/CD for building and publishing app in Docker image

## Workflow

1. Серверный билд срабатывает для ветки release с тэгом "v\d*"
2. Из тэга извлекается версия релиза (отбрасывается начальный символ 'v')
3. Если версия определена успешно, то запускается сборка образа

## Manually add tag and push

`
git add .

git commit -m "Version 1.5.2"

git tag v1.5.2

git push origin --tags

`
