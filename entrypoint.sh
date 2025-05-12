#!/bin/bash

cd /var/www

# 🧩 Verifica se o Laravel já está instalado
if [ ! -f artisan ] || [ ! -f composer.json ]; then
    echo "📦 Criando novo projeto Laravel e instalando Reverb..."

    # Remove arquivos residuais (exceto entrypoint)
    find . -mindepth 1 ! -name 'entrypoint.sh' -exec rm -rf {} +

    composer create-project laravel/laravel .
    composer require laravel/reverb

    echo "✅ Projeto Laravel criado com sucesso."
fi

if [ ! -f .env ]; then
    echo "📄 Gerando .env a partir das variáveis de ambiente..."
    cat <<EOF > .env
APP_NAME=${APP_NAME:-ReverbServer}
APP_ENV=${APP_ENV:-production}
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_LEVEL=info

BROADCAST_DRIVER=${BROADCAST_DRIVER:-pusher}
QUEUE_CONNECTION=sync
CACHE_DRIVER=array
SESSION_DRIVER=array

REVERB_APP_ID=${REVERB_APP_ID}
REVERB_APP_KEY=${REVERB_APP_KEY}
REVERB_APP_SECRET=${REVERB_APP_SECRET}

REDIS_CLIENT=phpredis
REDIS_HOST=${REDIS_HOST}
REDIS_PORT=${REDIS_PORT:-6379}

REVERB_HOST=0.0.0.0
REVERB_PORT=6001
REVERB_SCHEME=http
EOF
fi

# 🔑 Garante que APP_KEY esteja definida
if ! grep -q "^APP_KEY=" .env || grep -q "^APP_KEY=$" .env; then
    echo "🔑 Gerando APP_KEY..."
    php artisan key:generate
fi

echo "♻️ Limpando config/cache antigos..."
php artisan config:clear
php artisan cache:clear

echo "🚀 Iniciando Laravel Reverb..."
php artisan reverb:start --host=0.0.0.0 --port=6001
