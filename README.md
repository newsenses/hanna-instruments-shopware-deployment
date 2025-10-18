# 🚀 Shopware 6.6.10.1 LTS Deployment Package

Ein vollständiges Deployment-Paket für Shopware 6.6.10.1 LTS mit Docker Hub Integration.

## 📦 Was ist enthalten

- **Docker Images** auf Docker Hub: `hannainstruments/shopware-web:6.6.10.1 LTS` und `hannainstruments/shopware-database:6.6.10.1 LTS`
- **Automatische Deployment-Scripts** für verschiedene Umgebungen
- **Mittwald Studio Optimierung** mit speziellen Konfigurationen
- **Update- und Rollback-Funktionalität** für Wartung

## 🚀 Schnellstart

### Standard Deployment
```bash
git clone https://github.com/hannainstruments/shopware-deployment.git
cd shopware-deployment
chmod +x deploy.sh
./deploy.sh your-domain.com
```

### Mittwald Studio Deployment
```bash
git clone https://github.com/hannainstruments/shopware-deployment.git
cd shopware-deployment
chmod +x deploy-mittwald.sh
./deploy-mittwald.sh your-domain.de
```

## 📋 Voraussetzungen

- **Docker** und **Docker Compose** installiert
- **4GB+ RAM** verfügbar
- **Port 80 und 443** frei
- **Internetverbindung** für Docker Hub

## 🔧 Konfiguration

### Domain anpassen
Die Scripts passen automatisch die Domain in der Docker Compose Konfiguration an.

### SSL-Zertifikat (Mittwald)
1. SSL-Zertifikat in Mittwald Panel hochladen
2. Domain-DNS auf Mittwald Server zeigen lassen
3. SSL-Zertifikat aktivieren

## 📁 Dateien

| Datei | Beschreibung |
|-------|-------------|
| `docker-compose.yml` | Docker-Konfiguration für Docker Hub Images |
| `deploy.sh` | Standard-Deployment Script |
| `deploy-mittwald.sh` | Mittwald Studio optimiertes Script |
| `update.sh` | Update-Script für neuere Versionen |
| `rollback.sh` | Rollback-Script für vorherige Versionen |
| `shopware-files.tar.gz` | Shopware-Dateien (manuell hinzufügen) |
| `shopware-database.sql` | Datenbank-Dump (manuell hinzufügen) |

## 🐳 Docker Hub Images

- **Web Container**: `hannainstruments/shopware-web:6.6.10.1 LTS`
  - PHP 8.2 + Apache
  - Alle notwendigen Extensions
  - Composer installiert
  - SSL-Konfiguration

- **Database Container**: `hannainstruments/shopware-database:6.6.10.1 LTS`
  - MariaDB 10.11
  - Optimierte Konfiguration
  - Root-Zugang: `root/root`

## 🔄 Updates und Wartung

### Update auf neuere Version
```bash
./update.sh 6.6.10.1
```

### Rollback auf vorherige Version
```bash
./rollback.sh backup-20241016-143022
```

### Logs anzeigen
```bash
docker-compose logs
```

### Container neu starten
```bash
docker-compose restart
```

## 🏢 Mittwald Studio spezifisch

### Besondere Features
- **Automatische SSL-Konfiguration** für Mittwald
- **Domain-spezifische VirtualHosts**
- **Mittwald-optimierte Apache-Konfiguration**
- **Automatische HTTPS-Weiterleitung**

### Mittwald Panel Integration
- SSL-Zertifikate über Mittwald Panel verwalten
- Domain-DNS über Mittwald konfigurieren
- Backup-System von Mittwald nutzen

## 🛠️ Entwicklung

### Lokale Entwicklung
```bash
# Container starten
docker-compose up -d

# In Container einloggen
docker exec -it shopware_web bash

# Composer Commands
docker exec shopware_web bash -c "cd /var/www/html && composer install"

# Shopware Commands
docker exec shopware_web bash -c "cd /var/www/html && bin/console cache:clear"
```

### Custom Theme
Das Custom Theme ist bereits in den Docker Images enthalten und wird automatisch aktiviert.

## 📊 Monitoring

### Container Status
```bash
docker-compose ps
```

### Ressourcen-Verbrauch
```bash
docker stats
```

### Logs
```bash
# Alle Logs
docker-compose logs

# Spezifische Service Logs
docker-compose logs web
docker-compose logs database
```

## 🔒 Sicherheit

### Standard-Konfiguration
- **Root-Passwort**: `root` (für Entwicklung)
- **Database-User**: `shopware/shopware`
- **SSL**: Selbstsignierte Zertifikate (für Entwicklung)

### Produktions-Anpassungen
- Starke Passwörter setzen
- SSL-Zertifikate von vertrauenswürdiger CA
- Firewall-Regeln konfigurieren
- Regelmäßige Backups

## 🆘 Troubleshooting

### Container starten nicht
```bash
# Logs prüfen
docker-compose logs

# Container neu erstellen
docker-compose down
docker-compose up -d --force-recreate
```

### Datenbank-Verbindung fehlgeschlagen
```bash
# Datenbank-Status prüfen
docker exec shopware_database mysql -u root -proot -e "SHOW DATABASES;"

# Verbindung testen
docker exec shopware_web bash -c "cd /var/www/html && bin/console debug:container"
```

### Frontend zeigt Fehler
```bash
# Cache leeren
docker exec shopware_web bash -c "cd /var/www/html && bin/console cache:clear"

# Assets neu installieren
docker exec shopware_web bash -c "cd /var/www/html && bin/console assets:install"
```

## 📞 Support

Bei Problemen:
1. Logs prüfen: `docker-compose logs`
2. Container-Status prüfen: `docker-compose ps`
3. GitHub Issues erstellen
4. Dokumentation durchgehen

## 📄 Lizenz

MIT License - siehe LICENSE Datei für Details.

---

**Entwickelt für Hanna Instruments** 🏢
