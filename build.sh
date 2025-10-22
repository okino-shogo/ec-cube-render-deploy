#!/bin/bash
set -e

echo "🚀 Starting EC-CUBE build for Render..."

# Install PHP dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm ci

# Build frontend assets
echo "🎨 Building frontend assets..."
npm run build

# Clear and warm up cache
echo "🧹 Clearing and warming up cache..."
APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear --env=prod --no-debug

# Set proper permissions for var directory
echo "🔒 Setting permissions..."
chmod -R 777 var/

echo "✅ Build completed successfully!"