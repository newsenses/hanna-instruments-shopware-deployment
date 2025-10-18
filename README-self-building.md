# 🚀 Shopware 6.6.10.1 LTS - Self-Building Deployment

**Option B: Self-Building Deployment** - Mittwald baut automatisch alles selbst!

## 🎯 **Was ist Self-Building?**

**Statt große Docker Images zu übertragen:**
- ✅ Nur **Code + Konfiguration** hochladen
- ✅ Mittwald führt **automatisch** `composer install`, `npm install` aus
- ✅ **Kleinere Uploads** - keine großen Binaries
- ✅ **Einfacher zu debuggen** - Build-Logs zeigen alle Schritte

## 📦 **Was wird übertragen?**

### **Code-Dateien:**
- `composer.json` + `composer.lock` → PHP Dependencies
- `package.json` + `package-lock.json` → Node.js Dependencies  
- Alle Shopware-Dateien → Anwendungscode
- Custom Theme → `HannaInstrumentsTheme/`

### **Datenbank:**
- `shopware-database.sql` → **Alle Plugins + Einstellungen**
- Alle PayOne-Konfigurationen
- Alle Theme-Einstellungen
- Alle Custom Fields

## 🔧 **Wie funktioniert es?**

### **1. Code-Build (automatisch):**
```bash
# Mittwald führt automatisch aus:
composer install --no-dev --optimize-autoloader
npm install && npm run build
```

### **2. Datenbank-Import (automatisch):**
```bash
# Mittwald importiert automatisch:
mysql -u shopware -p shopware < shopware-database.sql
```

### **3. Shopware-Setup (automatisch):**
```bash
# Mittwald führt automatisch aus:
bin/console cache:clear
bin/console assets:install
bin/console theme:compile
```

## 🚀 **Deployment**

### **GitHub Actions:**
```yaml
# .github/workflows/deploy-self-building.yml
- Builds Docker Image mit allen Dependencies
- Pushes zu GitHub Container Registry
- Deploys zu Mittwald Studio
```

### **Mittwald Stack:**
```yaml
# mittwald-stack-self-building.yaml
services:
  web:
    image: ghcr.io/newsenses/hanna-instruments-shopware-deployment/self-building:latest
    # Mittwald baut automatisch alles
```

## 📊 **Vorteile vs. Vollständige Container**

| Aspekt | Self-Building | Vollständige Container |
|--------|---------------|------------------------|
| **Upload-Größe** | ~50MB | ~2GB |
| **Build-Zeit** | 5-10 Min | 1-2 Min |
| **Debugging** | ✅ Build-Logs | ❌ Nur Runtime-Logs |
| **Dependencies** | ✅ Immer aktuell | ❌ Können veraltet sein |
| **Flexibilität** | ✅ Einfach anpassbar | ❌ Image neu bauen |

## 🔍 **Was ist in der Datenbank enthalten?**

### **Alle aktiven Plugins:**
- ✅ **PayOnePayment** - Payment Gateway
- ✅ **HannaInstrumentsTheme** - Custom Theme
- ✅ **SolidAdvancedSliderElements** - CMS Slider
- ✅ **BarnB2B** - B2B Funktionalität
- ✅ **NetzpBlog6** - Blog System
- ✅ **AcrisPriceOnRequestCS** - Preis auf Anfrage
- ✅ **SwagPlatformSecurity** - Security Plugin
- ✅ **DIScoGA4** - Google Analytics
- ✅ **IwvOrdersCsvExporterV6** - CSV Export
- ✅ **ScopPlatformRedirecter** - Redirects
- ✅ **AcrisCountryTaxCS** - Ländersteuer

### **Alle Konfigurationen:**
- ✅ **PayOne-Einstellungen** (API Keys, Konfiguration)
- ✅ **Theme-Einstellungen** (Farben, Fonts, Layout)
- ✅ **Custom Fields** (Produktfelder, Kategorien)
- ✅ **Sales Channels** (Domains, Sprachen)
- ✅ **Payment Methods** (Zahlungsarten)
- ✅ **Shipping Methods** (Versandarten)

## 🛠️ **Lokale Entwicklung**

### **Test Self-Building lokal:**
```bash
# Build Image
docker build -f Dockerfile.self-building -t shopware-self-building .

# Run Container
docker run -p 8080:80 shopware-self-building

# Test
curl http://localhost:8080
```

### **Datenbank testen:**
```bash
# Import testen
mysql -u root -p shopware < shopware-database.sql

# Plugins prüfen
mysql -u root -p shopware -e "SELECT name, active FROM plugin WHERE active = 1;"
```

## 🔄 **Updates**

### **Code-Update:**
```bash
# 1. Code ändern
git add .
git commit -m "Update theme"
git push

# 2. GitHub Actions baut automatisch
# 3. Mittwald deployed automatisch
```

### **Plugin-Update:**
```bash
# 1. Plugin in lokaler DB aktualisieren
# 2. Neue DB exportieren
mysqldump -u root -p shopware > shopware-database.sql

# 3. Commit & Push
git add shopware-database.sql
git commit -m "Update plugins"
git push
```

## 🆘 **Troubleshooting**

### **Build-Fehler:**
```bash
# GitHub Actions Logs prüfen
# → Build-Schritt zeigt Composer/NPM Fehler
```

### **Plugin-Fehler:**
```bash
# Datenbank-Logs prüfen
# → MySQL Import-Fehler sichtbar
```

### **Theme-Fehler:**
```bash
# Shopware-Logs prüfen
# → Theme-Compilation-Fehler sichtbar
```

## 📞 **Support**

**Bei Problemen:**
1. **GitHub Actions Logs** prüfen (Build-Prozess)
2. **Mittwald Logs** prüfen (Runtime)
3. **Datenbank-Status** prüfen
4. **Plugin-Status** prüfen

---

**Entwickelt für Hanna Instruments** 🏢  
**Self-Building = Schneller + Flexibler + Debuggbarer** ⚡
