#!/bin/bash
set -e

echo "🚀 Starting EC-CUBE build for Render..."

# Create required directories first
echo "📁 Creating directories..."
mkdir -p var/cache var/log var/sessions html/upload/save_image html/upload/temp_image

# Install PHP dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm ci --only=production

# Build frontend assets
echo "🎨 Building frontend assets..."
npm run build

# Clear and warm up cache
echo "🧹 Clearing and warming up cache..."
APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear --env=prod --no-debug || true

# Set proper permissions
echo "🔒 Setting permissions..."
chown -R www-data:www-data .
chmod -R 755 .
chmod -R 777 var/ html/
find var -type f -exec chmod 666 {} \;
find var -type d -exec chmod 777 {} \;

echo "✅ Build completed successfully!"