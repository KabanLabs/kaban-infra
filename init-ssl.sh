#!/bin/bash

# Configuration
DOMAIN="REPLACE_ME_DOMAIN"
EMAIL="your-email@example.com" # Change this!
CHALLENGE_DIR="./certbot/www"
CONF_DIR="./certbot/conf"

if [ -d "$CONF_DIR/live/$DOMAIN" ]; then
  echo ">>> Existing data found for $DOMAIN. Skipping dummy certificate generation."
else
  echo ">>> Creating dummy certificate for $DOMAIN so Nginx can start..."
  mkdir -p "$CONF_DIR/live/$DOMAIN"
  docker compose -f docker-compose.prod.yml run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
      -keyout '/etc/letsencrypt/live/$DOMAIN/privkey.pem' \
      -out '/etc/letsencrypt/live/$DOMAIN/fullchain.pem' \
      -subj '/CN=localhost'" certbot
fi

echo ">>> Starting Nginx to handle ACME challenge..."
docker compose -f docker-compose.prod.yml up -d nginx

echo ">>> Deleting dummy certificate for $DOMAIN..."
docker compose -f docker-compose.prod.yml run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$DOMAIN && \
  rm -Rf /etc/letsencrypt/archive/$DOMAIN && \
  rm -Rf /etc/letsencrypt/renewal/$DOMAIN.conf" certbot

echo ">>> Requesting real SSL certificate for $DOMAIN..."
docker compose -f docker-compose.prod.yml run --rm certbot \
    certonly --webroot -w /var/www/certbot \
    --email "$EMAIL" --agree-tos --no-eff-email --force-renewal \
    -d "$DOMAIN"

echo ">>> Reloading Nginx to apply new certificates..."
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload

echo ">>> Done! SSL should be active now."
