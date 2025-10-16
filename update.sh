#!/bin/bash

# 🔄 Shopware Update Script
# =========================
# Für Updates auf neuere Versionen

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
NEW_VERSION=${1:-"6.6.10.1"}
DOCKER_USERNAME="newsensesmax"
CURRENT_VERSION="6.6.7.0"

echo "🔄 Shopware Update Script"
echo "========================"
echo "📦 Von: $CURRENT_VERSION"
echo "📦 Nach: $NEW_VERSION"
echo ""

# Backup erstellen
log_info "Erstelle Backup vor Update..."
BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p backups/$BACKUP_NAME

# Datenbank-Backup
log_info "Backup Datenbank..."
docker exec shopware_database mysqldump -u root -proot shopware > backups/$BACKUP_NAME/database.sql
log_success "Datenbank-Backup erstellt"

# Dateien-Backup
log_info "Backup Shopware-Dateien..."
tar -czf backups/$BACKUP_NAME/shopware-files.tar.gz shopware-files/
log_success "Dateien-Backup erstellt"

# Docker Images Backup
log_info "Backup Docker Images..."
docker save shopware_web | gzip > backups/$BACKUP_NAME/web-image.tar.gz
docker save shopware_database | gzip > backups/$BACKUP_NAME/database-image.tar.gz
log_success "Docker Images-Backup erstellt"

log_success "Backup abgeschlossen: backups/$BACKUP_NAME"

# Container stoppen
log_info "Stoppe Container..."
docker-compose down
log_success "Container gestoppt"

# Neue Images laden
log_info "Lade neue Docker Images..."
docker pull $DOCKER_USERNAME/shopware-web:$NEW_VERSION
docker pull $DOCKER_USERNAME/shopware-database:$NEW_VERSION
log_success "Neue Images geladen"

# Docker Compose aktualisieren
log_info "Aktualisiere Docker Compose..."
sed -i.bak "s/:$CURRENT_VERSION/:$NEW_VERSION/g" docker-compose.yml
log_success "Docker Compose aktualisiert"

# Container starten
log_info "Starte Container mit neuer Version..."
docker-compose up -d
log_success "Container gestartet"

# Warten
log_info "Warte auf Container-Bereitschaft..."
sleep 30

# Datenbank-Migration
log_info "Führe Datenbank-Migration durch..."
docker exec shopware_web bash -c "cd /var/www/html && bin/console database:migrate --all"
log_success "Datenbank-Migration abgeschlossen"

# Assets aktualisieren
log_info "Aktualisiere Assets..."
docker exec shopware_web bash -c "cd /var/www/html && composer install --no-interaction --no-dev"
docker exec shopware_web bash -c "cd /var/www/html && bin/console assets:install"
docker exec shopware_web bash -c "cd /var/www/html && bin/console cache:clear"
log_success "Assets aktualisiert"

# Theme kompilieren
log_info "Kompiliere Theme..."
docker exec shopware_web bash -c "cd /var/www/html && bin/console theme:compile"
log_success "Theme kompiliert"

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
echo "🎉 Update abgeschlossen!"
echo "========================"
echo "📦 Neue Version: $NEW_VERSION"
echo "💾 Backup: backups/$BACKUP_NAME"
echo ""
echo "🔧 Bei Problemen:"
echo "1. Rollback: ./rollback.sh $BACKUP_NAME"
echo "2. Logs prüfen: docker-compose logs"
echo "3. Manueller Rollback möglich"
