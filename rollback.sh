#!/bin/bash

# ↩️ Shopware Rollback Script
# ===========================
# Für Rollback auf vorherige Version

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Konfiguration
BACKUP_NAME=${1}

if [ -z "$BACKUP_NAME" ]; then
    echo "🔄 Shopware Rollback Script"
    echo "=========================="
    echo ""
    echo "Verfügbare Backups:"
    ls -la backups/ 2>/dev/null || echo "Keine Backups gefunden"
    echo ""
    echo "Verwendung: ./rollback.sh <backup-name>"
    echo "Beispiel:  ./rollback.sh backup-20241016-143022"
    exit 1
fi

BACKUP_PATH="backups/$BACKUP_NAME"

if [ ! -d "$BACKUP_PATH" ]; then
    log_error "Backup '$BACKUP_NAME' nicht gefunden!"
    echo "Verfügbare Backups:"
    ls -la backups/ 2>/dev/null || echo "Keine Backups gefunden"
    exit 1
fi

echo "↩️ Shopware Rollback"
echo "==================="
echo "📦 Backup: $BACKUP_NAME"
echo "📁 Pfad: $BACKUP_PATH"
echo ""

# Bestätigung
read -p "⚠️  Rollback wird alle aktuellen Daten überschreiben. Fortfahren? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Rollback abgebrochen"
    exit 1
fi

# Container stoppen
log_info "Stoppe Container..."
docker-compose down
log_success "Container gestoppt"

# Docker Images wiederherstellen
log_info "Stelle Docker Images wieder her..."
if [ -f "$BACKUP_PATH/web-image.tar.gz" ]; then
    docker load < "$BACKUP_PATH/web-image.tar.gz"
    log_success "Web-Image wiederhergestellt"
else
    log_warning "Web-Image Backup nicht gefunden"
fi

if [ -f "$BACKUP_PATH/database-image.tar.gz" ]; then
    docker load < "$BACKUP_PATH/database-image.tar.gz"
    log_success "Database-Image wiederhergestellt"
else
    log_warning "Database-Image Backup nicht gefunden"
fi

# Dateien wiederherstellen
log_info "Stelle Shopware-Dateien wieder her..."
if [ -f "$BACKUP_PATH/shopware-files.tar.gz" ]; then
    rm -rf shopware-files/
    tar -xzf "$BACKUP_PATH/shopware-files.tar.gz"
    log_success "Shopware-Dateien wiederhergestellt"
else
    log_warning "Shopware-Dateien Backup nicht gefunden"
fi

# Container starten
log_info "Starte Container..."
docker-compose up -d
log_success "Container gestartet"

# Warten
log_info "Warte auf Container-Bereitschaft..."
sleep 30

# Datenbank wiederherstellen
log_info "Stelle Datenbank wieder her..."
if [ -f "$BACKUP_PATH/database.sql" ]; then
    docker exec shopware_database mysql -u root -proot -e "DROP DATABASE IF EXISTS shopware; CREATE DATABASE shopware;"
    docker exec -i shopware_database mysql -u root -proot shopware < "$BACKUP_PATH/database.sql"
    log_success "Datenbank wiederhergestellt"
else
    log_warning "Datenbank-Backup nicht gefunden"
fi

# Assets installieren
log_info "Installiere Assets..."
docker exec shopware_web bash -c "cd /var/www/html && composer install --no-interaction --no-dev"
docker exec shopware_web bash -c "cd /var/www/html && bin/console assets:install"
docker exec shopware_web bash -c "cd /var/www/html && bin/console cache:clear"
log_success "Assets installiert"

# Tests
log_info "Führe Tests durch..."
sleep 10

if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
    log_success "Frontend funktioniert"
else
    log_warning "Frontend-Test fehlgeschlagen"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost/admin | grep -q "200"; then
    log_success "Backend funktioniert"
else
    log_warning "Backend-Test fehlgeschlagen"
fi

echo ""
echo "🎉 Rollback abgeschlossen!"
echo "=========================="
echo "📦 Wiederhergestellt: $BACKUP_NAME"
echo "🌐 Frontend: http://localhost"
echo "🔧 Backend:  http://localhost/admin"
echo ""
echo "💡 Tipp: Backup '$BACKUP_NAME' bleibt erhalten für weitere Rollbacks"
