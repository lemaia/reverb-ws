FROM php:8.3-cli

# Instala dependências do sistema e extensões necessárias
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev libonig-dev libxml2-dev libcurl4-openssl-dev \
    libssl-dev libevent-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql zip bcmath sockets pcntl

# Instala o Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Define o diretório de trabalho
WORKDIR /var/www

# Copia o script de inicialização e dá permissão de execução
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define o entrypoint
ENTRYPOINT ["entrypoint.sh"]
