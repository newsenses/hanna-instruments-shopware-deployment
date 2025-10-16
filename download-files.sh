#!/bin/bash

# 📥 Hanna Instruments Shopware Deployment Files Downloader
# ========================================================
# Lädt die großen Deployment-Dateien von einem externen Server herunter

set -e

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

echo "📥 Hanna Instruments Shopware Deployment Files Downloader"
echo "=========================================================="
echo ""

# Prüfe ob Dateien bereits vorhanden sind
if [ -f "shopware-files.tar.gz" ] && [ -f "shopware-database.sql" ]; then
    log_success "Deployment-Dateien bereits vorhanden!"
    echo "📁 shopware-files.tar.gz: $(ls -lh shopware-files.tar.gz | awk '{print $5}')"
    echo "📁 shopware-database.sql: $(ls -lh shopware-database.sql | awk '{print $5}')"
    echo ""
    echo "🚀 Bereit für Deployment:"
    echo "   ./deploy.sh your-domain.com"
    echo "   ./deploy-mittwald.sh your-domain.de"
    exit 0
fi

log_info "Deployment-Dateien werden benötigt..."
echo ""
echo "📋 Verfügbare Optionen:"
echo "1. 📁 Dateien manuell hinzufügen"
echo "2. 🔗 Download-Links bereitstellen"
echo "3. 🐳 Docker Images direkt verwenden (ohne Dateien)"
echo ""

read -p "Wähle eine Option (1-3): " choice

case $choice in
    1)
        log_info "Manuelle Dateien-Hinzufügung"
        echo ""
        echo "📁 Bitte füge folgende Dateien hinzu:"
        echo "   - shopware-files.tar.gz (Shopware-Dateien)"
        echo "   - shopware-database.sql (Datenbank-Dump)"
        echo ""
        echo "💡 Die Dateien können von der ursprünglichen Installation kopiert werden."
        ;;
    2)
        log_info "Download-Links bereitstellen"
        echo ""
        echo "🔗 Download-Links für Deployment-Dateien:"
        echo ""
        echo "📁 Shopware-Dateien:"
        echo "   - Größe: ~4.7GB"
        echo "   - Inhalt: Komplette Shopware 6.6.7.0 Installation"
        echo "   - Download: [Wird bereitgestellt]"
        echo ""
        echo "🗄️ Datenbank-Dump:"
        echo "   - Größe: ~462MB"
        echo "   - Inhalt: Produktionsdatenbank mit allen Daten"
        echo "   - Download: [Wird bereitgestellt]"
        echo ""
        echo "💡 Kontaktiere den Administrator für die Download-Links."
        ;;
    3)
        log_info "Docker Images ohne lokale Dateien verwenden"
        echo ""
        echo "🐳 Docker Images sind bereits auf Docker Hub verfügbar:"
        echo "   - newsensesmax/shopware-web:6.6.7.0"
        echo "   - newsensesmax/shopware-database:6.6.7.0"
        echo ""
        echo "⚠️  Hinweis: Ohne lokale Dateien wird eine leere Installation erstellt."
        echo "   Die Produktionsdaten müssen separat importiert werden."
        echo ""
        echo "🚀 Deployment trotzdem möglich:"
        echo "   ./deploy.sh your-domain.com"
        ;;
    *)
        log_warning "Ungültige Option"
        exit 1
        ;;
esac

echo ""
echo "📞 Support:"
echo "   - GitHub Issues: https://github.com/newsenses/hanna-instruments-shopware-deployment/issues"
echo "   - Email: info@newsenses.net"
echo "   - Website: https://www.newsenses.net"
