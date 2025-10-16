#!/bin/bash

# Wait for database to be ready
echo "Waiting for database to be ready..."
while ! mysqladmin ping -h"database" -u"root" -p"$MYSQL_ROOT_PASSWORD" --silent; do
    echo "Database is unavailable - sleeping"
    sleep 2
done

echo "Database is ready!"

# Import database if file exists
if [ -f "/var/www/html/shopware-database.sql" ]; then
    echo "Importing database..."
    mysql -h"database" -u"root" -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" < /var/www/html/shopware-database.sql
    echo "Database imported successfully!"
else
    echo "No database file found, creating empty database..."
    mysql -h"database" -u"root" -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
fi

# Start Apache
exec apache2-foreground
