#!/bin/bash
set -e

echo "🚀 Starting EC-CUBE application..."

# Set proper permissions
echo "🔒 Setting file permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 777 /var/www/html/var /var/www/html/html

# Create required directories
echo "📁 Creating required directories..."
mkdir -p /var/www/html/var/cache /var/www/html/var/log /var/www/html/var/sessions
mkdir -p /var/www/html/html/upload/save_image /var/www/html/html/upload/temp_image

# Wait for database to be ready
echo "⏳ Waiting for database..."
sleep 15

# Clear cache first
echo "🧹 Clearing cache..."
php bin/console cache:clear --env=prod --no-debug || true

# Install assets
echo "📁 Installing assets..."
php bin/console assets:install --symlink --relative html || true

# Run database migrations
echo "📊 Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction || echo "Migration skipped"

# Load fixtures for initial setup (only if needed)
if [ "$LOAD_FIXTURES" = "true" ]; then
    echo "📊 Loading initial data fixtures..."
    php bin/console eccube:fixtures:load --no-interaction || echo "Fixtures skipped"
fi

# Set final permissions
chmod -R 777 /var/www/html/var

# Start Apache
echo "🌐 Starting Apache web server..."
exec apache2-foreground