#!/bin/bash

# 🚀 Shopware 6.6.7.0 Deployment Script
# =====================================
# Automatisches Deployment von Docker Hub + GitHub

set -e  # Exit on any error

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging Funktionen
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
DOMAIN_NAME=${1:-"localhost"}
PROJECT_NAME="shopware-$(date +%Y%m%d-%H%M%S)"
DOCKER_USERNAME="hannainstruments"
SHOPWARE_VERSION="6.6.7.0"

echo "🚀 Shopware $SHOPWARE_VERSION Deployment"
echo "========================================"
echo "🌐 Domain: $DOMAIN_NAME"
echo "📦 Projekt: $PROJECT_NAME"
echo "🐳 Docker Hub: $DOCKER_USERNAME"
echo ""

# Prüfe Voraussetzungen
log_info "Prüfe Voraussetzungen..."

if ! command -v docker &> /dev/null; then
    log_error "Docker ist nicht installiert!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose ist nicht installiert!"
    exit 1
fi

log_success "Voraussetzungen erfüllt"

# Docker Images von Docker Hub laden
log_info "Lade Docker Images von Docker Hub..."
docker pull $DOCKER_USERNAME/shopware-web:$SHOPWARE_VERSION
docker pull $DOCKER_USERNAME/shopware-database:$SHOPWARE_VERSION
log_success "Docker Images geladen"

# Shopware-Dateien herunterladen
log_info "Lade Shopware-Dateien..."
if [ ! -f "shopware-files.tar.gz" ]; then
    log_warning "shopware-files.tar.gz nicht gefunden. Bitte manuell hinzufügen."
    log_info "Erstelle leeres Verzeichnis..."
    mkdir -p shopware-files
else
    log_info "Entpacke Shopware-Dateien..."
    tar -xzf shopware-files.tar.gz
fi
log_success "Shopware-Dateien bereit"

# Datenbank herunterladen
log_info "Lade Datenbank..."
if [ ! -f "shopware-database.sql" ]; then
    log_warning "shopware-database.sql nicht gefunden. Bitte manuell hinzufügen."
    log_info "Erstelle leere Datenbank..."
    touch shopware-database.sql
else
    log_success "Datenbank-Datei gefunden"
fi

# Domain in Docker Compose anpassen
log_info "Passe Domain-Konfiguration an..."
sed -i.bak "s/localhost/$DOMAIN_NAME/g" docker-compose.yml
log_success "Domain konfiguriert: $DOMAIN_NAME"

# Container starten
log_info "Starte Container..."
docker-compose up -d
log_success "Container gestartet"

# Warten bis Container bereit sind
log_info "Warte auf Container-Bereitschaft..."
sleep 30

# Container Status prüfen
log_info "Prüfe Container-Status..."
if docker-compose ps | grep -q "Up"; then
    log_success "Container laufen"
else
    log_error "Container starten fehlgeschlagen!"
    docker-compose logs
    exit 1
fi

# Datenbank importieren (falls vorhanden)
if [ -s "shopware-database.sql" ]; then
    log_info "Importiere Datenbank..."
    docker exec shopware_database mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS shopware;"
    docker exec -i shopware_database mysql -u root -proot shopware < shopware-database.sql
    log_success "Datenbank importiert"
else
    log_warning "Keine Datenbank-Datei gefunden - verwende leere Installation"
fi

# Assets installieren
log_info "Installiere Assets..."
docker exec shopware_web bash -c "cd /var/www/html && composer install --no-interaction --no-dev"
docker exec shopware_web bash -c "cd /var/www/html && bin/console assets:install"
docker exec shopware_web bash -c "cd /var/www/html && bin/console cache:clear"
log_success "Assets installiert"

# Berechtigungen setzen
log_info "Setze Berechtigungen..."
docker exec shopware_web bash -c "chown -R www-data:www-data /var/www/html/var"
docker exec shopware_web bash -c "chmod -R 755 /var/www/html/var"
log_success "Berechtigungen gesetzt"

# Finale Tests
log_info "Führe finale Tests durch..."
sleep 10

# HTTP Test
if curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN_NAME | grep -q "200"; then
    log_success "Frontend funktioniert"
else
    log_warning "Frontend-Test fehlgeschlagen - prüfe manuell"
fi

# Admin Test
if curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN_NAME/admin | grep -q "200"; then
    log_success "Backend funktioniert"
else
    log_warning "Backend-Test fehlgeschlagen - prüfe manuell"
fi

echo ""
echo "🎉 Deployment abgeschlossen!"
echo "============================"
echo "🌐 Frontend: http://$DOMAIN_NAME"
echo "🔧 Backend:  http://$DOMAIN_NAME/admin"
echo "🗄️ Database: localhost:3307 (root/root)"
echo ""
echo "📋 Nächste Schritte:"
echo "1. SSL-Zertifikat konfigurieren"
echo "2. Domain-DNS auf Server zeigen lassen"
echo "3. Theme aktivieren (falls nötig)"
echo "4. Admin-Benutzer erstellen"
echo ""
echo "🔧 Wartung:"
echo "- Logs: docker-compose logs"
echo "- Stop:  docker-compose down"
echo "- Start: docker-compose up -d"
echo "- Update: ./update.sh"
