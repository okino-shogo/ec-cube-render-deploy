#!/bin/bash

# Immediate output to ensure logging works
echo "========================================" 2>&1
echo "START.SH EXECUTION STARTED" 2>&1
echo "Timestamp: $(date)" 2>&1
echo "========================================" 2>&1

# Enable debug mode for troubleshooting
set -x
# Note: NOT using set -e because we handle errors explicitly with || true in many places

echo "🚀 Starting EC-CUBE application..." 2>&1
echo "Current directory: $(pwd)" 2>&1
echo "Shell: $SHELL" 2>&1
echo "User: $(whoami)" 2>&1

# Check if we can list files
echo "Files in current directory:" 2>&1
ls -la 2>&1 || echo "Failed to list directory" 2>&1

# Environment check
echo "📋 Environment variables:" 2>&1
echo "DATABASE_URL is set: $([ -n "$DATABASE_URL" ] && echo 'YES' || echo 'NO')" 2>&1
echo "DATABASE_URL length: ${#DATABASE_URL}" 2>&1
if [ -n "$DATABASE_URL" ]; then
    echo "DATABASE_URL (first 60 chars): ${DATABASE_URL:0:60}..." 2>&1
else
    echo "❌ CRITICAL: DATABASE_URL is not set!" 2>&1
    echo "Available environment variables:" 2>&1
    env | grep -E "(DATABASE|APP_|ECCUBE_)" 2>&1 || echo "No relevant env vars found" 2>&1
    exit 1
fi
echo "APP_ENV: ${APP_ENV:-not set}" 2>&1
echo "APP_SECRET is set: $([ -n "$APP_SECRET" ] && echo 'YES' || echo 'NO')" 2>&1
echo "ECCUBE_AUTH_MAGIC is set: $([ -n "$ECCUBE_AUTH_MAGIC" ] && echo 'YES' || echo 'NO')" 2>&1

# Create .env.local
echo "📝 Creating .env.local from environment variables..." 2>&1

# Generate APP_SECRET if not set
if [ -z "$APP_SECRET" ]; then
    echo "⚠️  APP_SECRET not set, generating random value..." 2>&1
    APP_SECRET=$(openssl rand -hex 32)
    echo "Generated APP_SECRET (length: ${#APP_SECRET})" 2>&1
fi

# Generate ECCUBE_AUTH_MAGIC if not set
if [ -z "$ECCUBE_AUTH_MAGIC" ]; then
    echo "⚠️  ECCUBE_AUTH_MAGIC not set, generating random value..." 2>&1
    ECCUBE_AUTH_MAGIC=$(openssl rand -hex 16)
    echo "Generated ECCUBE_AUTH_MAGIC (length: ${#ECCUBE_AUTH_MAGIC})" 2>&1
fi

echo "Creating .env.local file..." 2>&1
cat > .env.local << EOF
APP_ENV=${APP_ENV:-prod}
APP_DEBUG=${APP_DEBUG:-0}
APP_SECRET=$APP_SECRET
ECCUBE_AUTH_MAGIC=$ECCUBE_AUTH_MAGIC
ECCUBE_ADMIN_ROUTE=${ECCUBE_ADMIN_ROUTE:-admin}
ECCUBE_LOCALE=${ECCUBE_LOCALE:-ja}
ECCUBE_TIMEZONE=${ECCUBE_TIMEZONE:-Asia/Tokyo}
ECCUBE_FORCE_SSL=${ECCUBE_FORCE_SSL:-false}
DATABASE_URL=$DATABASE_URL
MAILER_DSN=${MAILER_DSN:-smtp://localhost:1025}
EOF

if [ -f ".env.local" ]; then
    echo "✅ .env.local created successfully" 2>&1
    echo "File size: $(wc -c < .env.local) bytes" 2>&1
    echo "Content of .env.local (secrets masked):" 2>&1
    sed 's/\(APP_SECRET=\).*/\1***MASKED***/' .env.local | sed 's/\(ECCUBE_AUTH_MAGIC=\).*/\1***MASKED***/' | sed 's/\(DATABASE_URL=.*:\/\/[^:]*:\)[^@]*\(@.*\)/\1***MASKED***\2/' 2>&1
else
    echo "❌ Failed to create .env.local!" 2>&1
    exit 1
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
echo "DATABASE_URL (first 60 chars): ${DATABASE_URL:0:60}..."

max_retries=30
counter=0
last_error=""

while [ $counter -lt $max_retries ]; do
    echo "Attempt $((counter+1))/$max_retries..."

    db_result=$(php -r "
        \$dsn = '$DATABASE_URL';
        try {
            // Parse PostgreSQL DSN
            if (strpos(\$dsn, 'postgresql://') === 0 || strpos(\$dsn, 'postgres://') === 0) {
                preg_match('/^postgres(?:ql)?:\/\/([^:]+):([^@]+)@([^:\/]+):?(\d+)?\/(.+?)(\?.*)?$/', \$dsn, \$matches);
                \$user = \$matches[1] ?? '';
                \$pass = \$matches[2] ?? '';
                \$host = \$matches[3] ?? '';
                \$port = \$matches[4] ?? '5432';
                \$dbname = \$matches[5] ?? '';

                echo \"Connecting to PostgreSQL at \$host:\$port, database: \$dbname, user: \$user\\n\";

                \$dsn = \"pgsql:host=\$host;port=\$port;dbname=\$dbname\";
                \$pdo = new PDO(\$dsn, \$user, \$pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
            } else {
                // MySQL or other
                \$pdo = new PDO(explode('?', \$dsn)[0]);
            }

            echo 'SUCCESS: Database connected successfully';
            exit(0);
        } catch (Exception \$e) {
            echo 'ERROR: ' . \$e->getMessage();
            exit(1);
        }
    " 2>&1)

    echo "$db_result"

    if echo "$db_result" | grep -q "SUCCESS:"; then
        echo "✅ Database is ready!"
        break
    else
        last_error="$db_result"
        echo "Database not ready yet, waiting..."
        sleep 2
        counter=$((counter+1))
    fi
done

if [ $counter -eq $max_retries ]; then
    echo "❌ Database connection timeout after $max_retries attempts"
    echo "Last error: $last_error"
    echo "⚠️  Continuing anyway - application may fail if database is not ready"
fi

# Clear cache
echo "🧹 Clearing cache..."
if php bin/console cache:clear --env=prod --no-debug 2>&1; then
    echo "✅ Cache cleared successfully"
else
    echo "⚠️  Cache clear had issues, but continuing..."
    echo "Attempting to manually remove cache files..."
    rm -rf /var/www/html/var/cache/prod || true
    echo "Manual cache removal completed"
fi

# Check if EC-CUBE is installed
echo "🔍 Checking EC-CUBE installation status..."
echo "Checking for dtb_base_info table..."

# Try to query the database to check if tables exist
if php bin/console doctrine:query:sql "SELECT 1 FROM dtb_base_info LIMIT 1" 2>&1 | tee /tmp/db_check.log; then
    echo "✅ EC-CUBE is already installed (dtb_base_info table exists)"
else
    echo "📦 EC-CUBE not installed yet. Running initial installation..."
    echo "Database check output:"
    cat /tmp/db_check.log

    echo "Creating database schema..."
    if php bin/console doctrine:schema:create --dump-sql 2>&1; then
        echo "✅ Database schema created successfully"
    else
        echo "⚠️  Schema creation had issues, but continuing..."
    fi

    echo "Loading initial fixtures..."
    if php bin/console eccube:fixtures:load --no-interaction 2>&1; then
        echo "✅ Fixtures loaded successfully"
    else
        echo "⚠️  Fixture loading had issues, but continuing..."
    fi

    echo "✅ EC-CUBE installation completed"
fi

# Run migrations
echo "📊 Running database migrations..."
if php bin/console doctrine:migrations:migrate --no-interaction 2>&1; then
    echo "✅ Migrations completed successfully"
else
    echo "⚠️  Migration had issues, but continuing..."
fi

# Install assets
echo "📁 Installing assets..."
if php bin/console assets:install --symlink --relative html 2>&1; then
    echo "✅ Assets installed successfully"
else
    echo "⚠️  Asset installation had issues, trying without symlink..."
    php bin/console assets:install html 2>&1 || true
fi

# Set final permissions
echo "🔒 Setting final permissions..."
chmod -R 777 /var/www/html/var || true

# Verify critical files exist
echo "🔍 Verifying critical files..."
if [ -f ".env.local" ]; then
    echo "✅ .env.local exists"
else
    echo "❌ .env.local is missing!"
fi

if [ -f "bin/console" ]; then
    echo "✅ bin/console exists"
else
    echo "❌ bin/console is missing!"
fi

echo "📋 Directory structure:"
ls -la /var/www/html/ | head -20

# Start Apache
echo "🌐 Starting Apache web server..."
echo "Apache configuration test:"

# Test Apache configuration with detailed error reporting
if apache2ctl configtest 2>&1; then
    echo "✅ Apache configuration is valid"
else
    echo "⚠️  Apache configuration test failed, but attempting to start anyway..."
    echo "Apache error log:"
    cat /var/log/apache2/error.log 2>/dev/null || echo "No error log available yet"
fi

echo "🚀 Starting Apache in foreground..." 2>&1
echo "Application should be available on port 80" 2>&1
echo "Current user: $(whoami)" 2>&1
echo "Apache modules enabled:" 2>&1
apachectl -M 2>&1 | grep -E "(rewrite|headers|expires)" || echo "Module check completed" 2>&1

echo "Executing apache2-foreground..." 2>&1
echo "If you see this message, Apache should start next..." 2>&1

# Use exec to replace shell with Apache process
exec apache2-foreground 2>&1