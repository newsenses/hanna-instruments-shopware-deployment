#!/bin/bash

echo "Starting Shopware container..."

# Create a simple test page first
echo "Creating test page..."
cat > /var/www/html/public/test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <h1>✅ Container läuft!</h1>
    <p>Domain: <?php echo $_SERVER['HTTP_HOST'] ?? 'localhost'; ?></p>
    <p>Time: <?php echo date('Y-m-d H:i:s'); ?></p>
    <p>PHP Version: <?php echo phpversion(); ?></p>
</body>
</html>
EOF

# Wait for database to be ready using PHP
echo "Waiting for database to be ready..."
while ! php -r "
try {
    \$pdo = new PDO('mysql:host=database;port=3306', 'root', getenv('MYSQL_ROOT_PASSWORD'));
    echo 'Database is ready!' . PHP_EOL;
    exit(0);
} catch (Exception \$e) {
    exit(1);
}
"; do
    echo "Database is unavailable - sleeping"
    sleep 2
done

echo "Database is ready!"

# Import database if file exists using PHP
if [ -f "/var/www/html/shopware-database.sql" ]; then
    echo "Importing database using PHP..."
    php -r "
    \$pdo = new PDO('mysql:host=database;port=3306', 'root', getenv('MYSQL_ROOT_PASSWORD'));
    \$sql = file_get_contents('/var/www/html/shopware-database.sql');
    \$pdo->exec(\$sql);
    echo 'Database imported successfully!' . PHP_EOL;
    "
else
    echo "No database file found, creating empty database..."
    php -r "
    \$pdo = new PDO('mysql:host=database;port=3306', 'root', getenv('MYSQL_ROOT_PASSWORD'));
    \$pdo->exec('CREATE DATABASE IF NOT EXISTS ' . getenv('MYSQL_DATABASE'));
    echo 'Empty database created!' . PHP_EOL;
    "
fi

# Start Apache
exec apache2-foreground
