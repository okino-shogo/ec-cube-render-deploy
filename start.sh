#!/bin/bash
# Enable debug mode for troubleshooting
set -x

echo "🚀 Starting EC-CUBE application..."
echo "Current directory: $(pwd)"
echo "Files in current directory:"
ls -la

# Environment check
echo "📋 Environment variables:"
echo "DATABASE_URL: ${DATABASE_URL:0:50}..."
echo "APP_ENV: $APP_ENV"
echo "ECCUBE_AUTH_MAGIC is set: $([ -n "$ECCUBE_AUTH_MAGIC" ] && echo 'YES' || echo 'NO')"

# Create .env.local if environment variables are set
if [ -n "$DATABASE_URL" ] && [ -n "$APP_SECRET" ]; then
    echo "📝 Creating .env.local from environment variables..."
    cat > .env.local << EOF
APP_ENV=prod
APP_SECRET=$APP_SECRET
ECCUBE_AUTH_MAGIC=$ECCUBE_AUTH_MAGIC
ECCUBE_ADMIN_ROUTE=${ECCUBE_ADMIN_ROUTE:-admin}
ECCUBE_LOCALE=${ECCUBE_LOCALE:-ja}
ECCUBE_TIMEZONE=${ECCUBE_TIMEZONE:-Asia/Tokyo}
ECCUBE_FORCE_SSL=${ECCUBE_FORCE_SSL:-false}
DATABASE_URL=$DATABASE_URL
MAILER_DSN=${MAILER_DSN:-smtp://localhost:1025}
EOF
    echo ".env.local created successfully"
fi

# Set proper permissions
echo "🔒 Setting file permissions..."
chown -R www-data:www-data /var/www/html || true
chmod -R 755 /var/www/html || true
chmod -R 777 /var/www/html/var /var/www/html/html || true

# Create required directories
echo "📁 Creating required directories..."
mkdir -p /var/www/html/var/cache /var/www/html/var/log /var/www/html/var/sessions || true
mkdir -p /var/www/html/html/upload/save_image /var/www/html/html/upload/temp_image || true

# Wait for database with retry logic
echo "⏳ Waiting for database connection..."
max_retries=30
counter=0
while [ $counter -lt $max_retries ]; do
    if php -r "
        \$dsn = '$DATABASE_URL';
        try {
            if (strpos(\$dsn, 'postgresql://') === 0 || strpos(\$dsn, 'postgres://') === 0) {
                \$dsn = str_replace(['postgresql://', 'postgres://'], 'pgsql:', \$dsn);
                \$dsn = preg_replace('/^pgsql:\/\/([^:]+):([^@]+)@([^:\/]+):?(\d+)?\/(.+)$/', 'pgsql:host=\$3;port=\$4;dbname=\$5;user=\$1;password=\$2', \$dsn);
            }
            \$pdo = new PDO(explode('?', \$dsn)[0]);
            echo 'Database connected successfully';
            exit(0);
        } catch (Exception \$e) {
            echo 'Database connection failed: ' . \$e->getMessage();
            exit(1);
        }
    "; then
        echo "✅ Database is ready!"
        break
    fi
    echo "Database not ready yet, waiting... (attempt $((counter+1))/$max_retries)"
    sleep 2
    counter=$((counter+1))
done

if [ $counter -eq $max_retries ]; then
    echo "❌ Database connection timeout after $max_retries attempts"
    # Continue anyway - maybe database will be ready later
fi

# Clear cache
echo "🧹 Clearing cache..."
php bin/console cache:clear --env=prod --no-debug || true

# Check if EC-CUBE is installed
echo "🔍 Checking EC-CUBE installation status..."
if php bin/console doctrine:query:sql "SELECT 1 FROM dtb_base_info LIMIT 1" 2>/dev/null; then
    echo "✅ EC-CUBE is already installed"
else
    echo "📦 EC-CUBE not installed. Running initial installation..."
    
    # Create database schema
    php bin/console doctrine:schema:create || true
    
    # Load initial data
    php bin/console eccube:fixtures:load --no-interaction || true
    
    echo "✅ EC-CUBE installation completed"
fi

# Run migrations
echo "📊 Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction || true

# Install assets
echo "📁 Installing assets..."
php bin/console assets:install --symlink --relative html || true

# Set final permissions
chmod -R 777 /var/www/html/var || true

# Start Apache
echo "🌐 Starting Apache web server..."
echo "Apache configuration test:"
apache2ctl configtest

echo "Starting Apache in foreground..."
exec apache2-foreground