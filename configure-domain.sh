#!/bin/bash

# Default values
DOMAIN=${DOMAIN:-"your-domain.com"}
EMAIL=${EMAIL:-"admin@$DOMAIN"}

echo ">>> Configuring project for domain: $DOMAIN"
echo ">>> Using email for SSL: $EMAIL"

# List of files to update
FILES=(
    "./docker-compose.prod.yml"
    "./nginx/nginx.conf"
    "./init-ssl.sh"
    "./configs/front/environment.production.ts"
)

# Replace placeholder with actual domain
# Note: Using | as delimiter for sed to avoid issues with slashes in URLs if any
for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo ">>> Updating $FILE..."
        # Replace REPLACE_ME_DOMAIN with actual domain
        sed -i "s|REPLACE_ME_DOMAIN|$DOMAIN|g" "$FILE"
        # Specifically for init-ssl.sh email
        if [ "$FILE" == "./init-ssl.sh" ]; then
            sed -i "s|your-email@example.com|$EMAIL|g" "$FILE"
        fi
    else
        echo ">>> Warning: $FILE not found, skipping."
    fi
done

echo ">>> Configuration complete. You can now run ./init-ssl.sh"
