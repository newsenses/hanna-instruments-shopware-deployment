#!/bin/bash

# 🏢 Mittwald Studio - Shopware 6.6.7.0 Deployment
# ================================================
# Speziell optimiert für Mittwald Studio Umgebung

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

# Mittwald-spezifische Konfiguration
DOMAIN_NAME=${1:-"your-domain.de"}
PROJECT_NAME="shopware-mittwald-$(date +%Y%m%d)"

echo "🏢 Mittwald Studio - Shopware Deployment"
echo "========================================"
echo "🌐 Domain: $DOMAIN_NAME"
echo "📦 Projekt: $PROJECT_NAME"
echo ""

# Mittwald-Umgebungsvariablen setzen
export COMPOSE_PROJECT_NAME=$PROJECT_NAME
export DOMAIN_NAME=$DOMAIN_NAME

log_info "Konfiguriere für Mittwald Studio..."

# Docker Compose für Mittwald anpassen
if [ -f "docker-compose.yml" ]; then
    # Domain anpassen
    sed -i.bak "s/localhost/$DOMAIN_NAME/g" docker-compose.yml
    sed -i.bak "s/hannainst.de/$DOMAIN_NAME/g" docker-compose.yml
    sed -i.bak "s/hannainst.ch/$DOMAIN_NAME/g" docker-compose.yml
    
    # Mittwald-spezifische Ports (falls nötig)
    # sed -i.bak "s/80:80/8080:80/g" docker-compose.yml
    
    log_success "Docker Compose für Mittwald konfiguriert"
else
    log_warning "docker-compose.yml nicht gefunden!"
    exit 1
fi

# Mittwald-spezifische Umgebungsvariablen
log_info "Setze Mittwald-Umgebungsvariablen..."
export MITTWALD_MODE=true
export MITTWALD_DOMAIN=$DOMAIN_NAME

# Standard-Deployment ausführen
log_info "Starte Standard-Deployment..."
./deploy.sh $DOMAIN_NAME

# Mittwald-spezifische Nachkonfiguration
log_info "Mittwald-spezifische Nachkonfiguration..."

# SSL-Konfiguration für Mittwald
log_info "Konfiguriere SSL für Mittwald..."
docker exec shopware_web bash -c "
    # Mittwald SSL-Zertifikat Pfade
    echo 'SSL_CERT_PATH=/etc/ssl/certs/mittwald.crt' >> /var/www/html/.env
    echo 'SSL_KEY_PATH=/etc/ssl/private/mittwald.key' >> /var/www/html/.env
"

# Mittwald-spezifische Apache-Konfiguration
log_info "Konfiguriere Apache für Mittwald..."
docker exec shopware_web bash -c "
    # Mittwald VirtualHost
    cat > /etc/apache2/sites-available/mittwald.conf << 'EOF'
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    ServerAlias www.$DOMAIN_NAME
    DocumentRoot /var/www/html/public
    
    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>
    
    # Redirect to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

<VirtualHost *:443>
    ServerName $DOMAIN_NAME
    ServerAlias www.$DOMAIN_NAME
    DocumentRoot /var/www/html/public
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/mittwald.crt
    SSLCertificateKeyFile /etc/ssl/private/mittwald.key
    
    <Directory /var/www/html/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    
    a2ensite mittwald
    a2dissite 000-default
    apache2ctl graceful
"

log_success "Mittwald-Konfiguration abgeschlossen"

echo ""
echo "🎉 Mittwald-Deployment abgeschlossen!"
echo "====================================="
echo "🌐 Domain: https://$DOMAIN_NAME"
echo "🔧 Admin:  https://$DOMAIN_NAME/admin"
echo ""
echo "📋 Mittwald-spezifische Schritte:"
echo "1. SSL-Zertifikat in Mittwald Panel hochladen"
echo "2. Domain-DNS auf Mittwald Server zeigen lassen"
echo "3. Mittwald SSL-Zertifikat aktivieren"
echo "4. Theme aktivieren (falls nötig)"
echo ""
echo "🔧 Mittwald-Wartung:"
echo "- Logs: docker-compose logs"
echo "- SSL-Update: Mittwald Panel verwenden"
echo "- Backup: Mittwald Backup-System nutzen"
