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

# Re-run rebranding script to update any new "Dify" text from upstream
.\whitelabel\rebrand.ps1
```

## 🔤 Rebranding (Dify → Dooza)

The `rebrand.ps1` script replaces all "Dify" text with "Dooza" across:
- **22 language directories** (660 i18n JSON files)
- **Frontend components** (logo alt text, icon names)

```powershell
# Preview changes without modifying files
.\whitelabel\rebrand.ps1 -DryRun

# Apply all changes
.\whitelabel\rebrand.ps1

# Only rebrand i18n files
.\whitelabel\rebrand.ps1 -I18nOnly

# Only rebrand component files  
.\whitelabel\rebrand.ps1 -ComponentsOnly
```

**Note:** Always re-run this script after merging upstream updates.

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
| `web/i18n/**/*.json` | All "Dify" → "Dooza" text (660 files) |
| `web/public/manifest.json` | Name: "Dooza AI", theme: #10B981 |
| `web/app/layout.tsx` | Theme color & app title |
| `web/app/components/base/logo/dify-logo.tsx` | Logo alt text |
| `web/public/browserconfig.xml` | Tile color |
| `web/public/favicon.ico` | Your favicon |
| `web/public/apple-touch-icon.png` | Your icon |
| `web/public/logo/logo-site.png` | Your logo |

## 🎨 Theme Color Reference

- **Primary:** `#10B981` (Emerald 500)
- **Hover:** `#059669` (Emerald 600)  
- **Light:** `#D1FAE5` (Emerald 100)
- **Dark:** `#047857` (Emerald 700)
