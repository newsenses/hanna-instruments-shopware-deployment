# Mittwald Studio Deployment Guide

## 🚀 Automatisches Deployment mit GitHub Actions

### 1. **Mittwald API Token erstellen:**
- Gehe ins [Mittwald Panel](https://studio.mittwald.de)
- **API Tokens** → **Neuer Token**
- **Berechtigung:** Container Management
- **Token kopieren** und als `MITTWALD_API_TOKEN` in GitHub Secrets speichern

### 2. **Stack-ID ermitteln:**
```bash
# Via API (mit deinem Token)
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  "https://api.mittwald.de/v2/containers/stacks"

# Oder im Mittwald Panel unter "Container" → "Stacks"
```

### 3. **GitHub Secrets konfigurieren:**
- `MITTWALD_API_TOKEN` - Dein API Token
- `MITTWALD_STACK_ID` - Deine Stack-ID
- `MYSQL_ROOT_PASSWORD` - Root Passwort für DB
- `MYSQL_PASSWORD` - User Passwort für DB
- `SHOPWARE_SECRET` - Shopware App Secret

### 4. **Deployment starten:**
```bash
# Push zu main branch oder
# Manuell via GitHub Actions → "Deploy Shopware to Mittwald"
```

## 🔧 **Manuelle Konfiguration (Alternative)**

### **Via Mittwald Panel:**
1. **Container-Service aktivieren**
2. **Stack erstellen:**
   - **Web:** `newsensesmax/shopware-web:6.6.7.0`
   - **Database:** `newsensesmax/shopware-database:6.6.7.0`
3. **Volumes konfigurieren**
4. **Environment Variables setzen**

### **Via API:**
```bash
# Stack erstellen
curl -X POST \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d @mittwald-stack.yaml \
  "https://api.mittwald.de/v2/containers/stacks"
```

## 📋 **Vorteile dieser Lösung:**

✅ **Kein Docker auf dem Server nötig**  
✅ **Automatisches Deployment via GitHub**  
✅ **Verwaltung über Mittwald Panel**  
✅ **Skalierbar und professionell**  
✅ **Rollback möglich**  

## 🎯 **Nächste Schritte:**

1. **API Token erstellen**
2. **Stack-ID ermitteln** 
3. **GitHub Secrets konfigurieren**
4. **Deployment testen**
