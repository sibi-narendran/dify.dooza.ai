# 🏷️ Dooza AI White-Label Deployment

**Theme Color:** `#10B981` (Light Green / Emerald)

## ✅ Assets Ready

```
whitelabel/web/public/
├── favicon.ico          ✅
├── favicon.png          ✅
├── favicon-32x32.png    ✅
├── apple-touch-icon.png ✅
├── manifest.json        ✅
└── logo/
    └── logo.png         ✅
```

## 🚀 Deploy

### Option 1: Docker Compose (Recommended)

```bash
cd docker
docker compose -f docker-compose.yaml -f ../whitelabel/docker/docker-compose.override.yml up -d
```

### Option 2: Direct Deployment

The assets have already been copied to `web/public/`. Just run:

```bash
cd docker
docker compose up -d
```

## 🔄 Sync Upstream Updates

```bash
git fetch upstream
git merge upstream/main
# Resolve any conflicts, your whitelabel/ files are yours
```

## ⚙️ Configuration

Edit `docker/.env` with your production settings:

```env
# URLs
CONSOLE_API_URL=https://api.dooza.ai
CONSOLE_WEB_URL=https://app.dooza.ai

# Security (CHANGE THESE!)
SECRET_KEY=generate-with-openssl-rand-base64-48
DB_PASSWORD=secure-password
REDIS_PASSWORD=secure-password

# Disable telemetry
SCARF_NO_ANALYTICS=true
NEXT_TELEMETRY_DISABLED=1
```

## 📝 Files Modified for White-Label

| File | Change |
|------|--------|
| `web/public/manifest.json` | Name: "Dooza AI", theme: #10B981 |
| `web/app/layout.tsx` | Theme color & app title |
| `web/public/browserconfig.xml` | Tile color |
| `web/public/favicon.ico` | Your favicon |
| `web/public/apple-touch-icon.png` | Your icon |
| `web/public/logo/logo-site.png` | Your logo |

## 🎨 Theme Color Reference

- **Primary:** `#10B981` (Emerald 500)
- **Hover:** `#059669` (Emerald 600)  
- **Light:** `#D1FAE5` (Emerald 100)
- **Dark:** `#047857` (Emerald 700)
