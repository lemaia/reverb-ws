#!/bin/bash

# 1. Prompt interativo
read -p "📧 Digite o e-mail para o Certbot: " EMAIL
read -p "🌐 Digite o domínio (ex: reverb.seudominio.com): " DOMAIN

# 2. Validação básica
if [ -z "$EMAIL" ] || [ -z "$DOMAIN" ]; then
  echo "❌ E-mail e domínio são obrigatórios."
  exit 1
fi

# 3. Atualizar .env
if grep -q "^REVERB_DOMAIN=" .env; then
  sed -i.bak "s/^REVERB_DOMAIN=.*/REVERB_DOMAIN=$DOMAIN/" .env
else
  echo "REVERB_DOMAIN=$DOMAIN" >> .env
fi

echo "✅ .env atualizado com REVERB_DOMAIN=$DOMAIN"

# 4. Atualizar nginx.conf e nginx.local.conf
for FILE in nginx/nginx.conf nginx/nginx.local.conf; do
  if [ -f "$FILE" ]; then
    sed -i.bak "s/server_name .*/server_name $DOMAIN;/" $FILE
    echo "✅ $FILE atualizado com domínio $DOMAIN"
  fi
done

# 5. Checar certificado existente
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

if [ -f "$CERT_PATH" ]; then
  echo "✅ Certificado já existe: $CERT_PATH"
  exit 0
fi

# 6. Gerar certificado via docker certbot
echo "🔐 Gerando certificado SSL para $DOMAIN com e-mail $EMAIL..."

docker run --rm \
  -v "$(pwd)/certbot/webroot:/var/www/certbot" \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
  certbot/certbot certonly \
  --webroot --webroot-path=/var/www/certbot \
  --email "$EMAIL" --agree-tos --no-eff-email \
  -d "$DOMAIN"

echo "✅ Certificado gerado com sucesso!"
