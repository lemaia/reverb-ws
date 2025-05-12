#!/bin/bash

set -e

# Carrega variáveis do .env
source .env

if [ -z "$REVERB_DOMAIN" ]; then
  echo "❌ Variável REVERB_DOMAIN não encontrada no .env"
  exit 1
fi

# Verifica se o certificado já existe
if [ -f "/etc/letsencrypt/live/$REVERB_DOMAIN/fullchain.pem" ]; then
  echo "✅ Certificado SSL já existe para $REVERB_DOMAIN. Pulando geração."
  touch .cert-ok
  exit 0
fi

# Solicita novo certificado via webroot
echo "🔐 Gerando certificado SSL para $REVERB_DOMAIN..."

docker-compose run --rm certbot certonly \
  --webroot -w /var/www/certbot \
  --email you@example.com \
  -d $REVERB_DOMAIN \
  --agree-tos \
  --non-interactive

# Marca como gerado com sucesso
touch .cert-ok

echo "✅ Certificado gerado com sucesso."
