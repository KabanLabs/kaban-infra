#!/bin/bash

# Останавливаем скрипт при ошибках
set -e

# Массив с репозиториями
REPOS=(
    "git@github.com:VACdotCS/kaban-front.git"
    "git@github.com:VACdotCS/kaban-nest-service.git"
    "git@github.com:VACdotCS/kaban-go-auth-service.git"
    "git@github.com:KabanLabs/kaban-go-service.git"
)

echo ">>> Начинаем загрузку репозиториев..."

for REPO in "${REPOS[@]}"; do
    REPO_NAME=$(basename "$REPO" .git)
    
    if [ -d "$REPO_NAME" ]; then
        echo ">>> Репозиторий $REPO_NAME уже существует, выполняем git pull..."
        git -C "$REPO_NAME" pull
    else
        echo ">>> Клонируем $REPO_NAME..."
        git clone "$REPO"
    fi
done

echo ">>> Запускаем инфраструктуру (docker compose up -d --build)..."
# Отключаем set -e для ручной обработки ошибки docker compose
set +e

docker compose up -d --build
UP_EXIT_CODE=$?

if [ $UP_EXIT_CODE -ne 0 ]; then
    echo ">>> ОШИБКА: Не удалось собрать или запустить контейнеры!"
    echo ">>> Убиваем инфраструктуру..."
    docker compose down
    exit 1
fi

echo ">>> Даём сервисам 10 секунд на инициализацию для проверки крашей..."
sleep 10

# Ищем контейнеры, которые упали (exited), находятся в циклическом рестарте (restarting) или мертвы (dead)
FAILED_SERVICES=$(docker compose ps --filter "status=exited" --filter "status=restarting" --filter "status=dead" --services)

if [ -n "$FAILED_SERVICES" ]; then
    echo ">>> ОШИБКА: Следующие сервисы упали или не смогли нормально стартовать:"
    echo "$FAILED_SERVICES"
    echo ""
    echo ">>> Последние логи проблемных сервисов:"
    docker compose logs --tail=50 $FAILED_SERVICES
    echo ""
    echo ">>> Убиваем всю инфраструктуру, так как не все сервисы успешно запущены..."
    docker compose down
    exit 1
fi

# Возвращаем проверку на ошибки
set -e

echo ">>> Все контейнеры успешно запущены и работают стабильно!"
docker compose ps
