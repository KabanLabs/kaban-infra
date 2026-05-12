#!/bin/bash

# Configuration
DOMAIN="REPLACE_ME_DOMAIN"
EMAIL="your-email@example.com" # Change this!
CHALLENGE_DIR="./certbot/www"
CONF_DIR="./certbot/conf"

echo ">>> Creating directories for Certbot..."
mkdir -p "$CHALLENGE_DIR" "$CONF_DIR"

echo ">>> Starting Nginx to handle ACME challenge..."
docker compose -f docker-compose.prod.yml up -d nginx

echo ">>> Requesting SSL certificate for $DOMAIN..."
docker compose -f docker-compose.prod.yml run --rm certbot \
    certonly --webroot -w /var/www/certbot \
    --email "$EMAIL" --agree-tos --no-eff-email \
    -d "$DOMAIN"

echo ">>> Reloading Nginx to apply certificates..."
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload

echo ">>> Done! SSL should be active now."
