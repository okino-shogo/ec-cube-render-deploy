#!/bin/bash
set -e

echo "🚀 Starting EC-CUBE application..."

# Wait for database to be ready
echo "⏳ Waiting for database..."
sleep 10

# Run database migrations
echo "📊 Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction || true

# Load fixtures for initial setup (only if needed)
if [ "$LOAD_FIXTURES" = "true" ]; then
    echo "📊 Loading initial data fixtures..."
    php bin/console eccube:fixtures:load --no-interaction || true
fi

# Install assets
echo "📁 Installing assets..."
php bin/console assets:install --symlink --relative html

# Start PHP-FPM or Apache
echo "🌐 Starting web server..."
exec apache2-foreground