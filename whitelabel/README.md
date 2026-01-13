# Dooza AI White-Label Deployment

**Theme Color:** `#10B981` (Emerald)

## Quick Start

```powershell
# Apply all whitelabel changes (assets + text rebrand)
.\whitelabel\apply-whitelabel.ps1

# Deploy
.\whitelabel\apply-whitelabel.ps1 -Deploy
```

## Long-Term Maintenance

### After pulling upstream updates:

```powershell
git fetch upstream
git merge upstream/main

# Re-apply whitelabel (handles new Dify text from upstream)
.\whitelabel\apply-whitelabel.ps1
```

This single command:
1. Copies your brand assets to production
2. Runs text rebrand (Dify → Dooza) on all i18n files

---

## Asset Checklist

### Logo Files (whitelabel/web/public/logo/)

| File | Size | Purpose | Required |
|------|------|---------|----------|
| `logo.svg` | 48x22 | Main logo (header, auth) | ✅ YES |
| `logo-monochrome-white.svg` | 48x22 | Dark mode logo | ✅ YES |
| `logo-site.png` | 64x64 | Webapp header icon | ✅ YES |
| `logo-site-dark.png` | 64x64 | Dark mode header | Optional |
| `logo-embedded-chat-avatar.png` | 40x40 | Chat widget avatar | Optional |
| `logo-embedded-chat-header.png` | 80x20 | Chat widget header | Optional |
| `logo-embedded-chat-header@2x.png` | 160x40 | Retina chat header | Optional |
| `logo-embedded-chat-header@3x.png` | 240x60 | 3x retina | Optional |

### Favicon/Icons (whitelabel/web/public/)

| File | Size | Status |
|------|------|--------|
| `favicon.ico` | 32x32 | ✅ EXISTS |
| `favicon-32x32.png` | 32x32 | ✅ EXISTS |
| `apple-touch-icon.png` | 180x180 | ✅ EXISTS |
| `manifest.json` | - | ✅ EXISTS |
| `icon-192x192.png` | 192x192 | Optional (PWA) |
| `icon-512x512.png` | 512x512 | Optional (PWA) |

---

## Scripts

| Script | Purpose |
|--------|---------|
| `apply-whitelabel.ps1` | Main script - syncs assets + rebrand |
| `rebrand.ps1` | Text replacement only (Dify → Dooza) |

### Script Options

```powershell
# Preview changes without modifying
.\whitelabel\apply-whitelabel.ps1 -DryRun

# Only sync assets (skip text rebrand)
.\whitelabel\apply-whitelabel.ps1 -AssetsOnly

# Build custom Docker image
.\whitelabel\apply-whitelabel.ps1 -Build

# Deploy with docker compose
.\whitelabel\apply-whitelabel.ps1 -Deploy
```

---

## Docker Deployment

### Option 1: Use override file (recommended)

```bash
cd docker
docker compose -f docker-compose.yaml -f ../whitelabel/docker/docker-compose.override.yml up -d
```

### Option 2: Build custom image

```powershell
.\whitelabel\apply-whitelabel.ps1 -Build -Deploy
```

---

## Configuration

Edit `docker/.env`:

```env
CONSOLE_API_URL=https://api.dooza.ai
CONSOLE_WEB_URL=https://app.dooza.ai

SECRET_KEY=generate-with-openssl-rand-base64-48
DB_PASSWORD=secure-password
REDIS_PASSWORD=secure-password

SCARF_NO_ANALYTICS=true
NEXT_TELEMETRY_DISABLED=1
```

---

## Theme Colors

| Usage | Color | Hex |
|-------|-------|-----|
| Primary | Emerald 500 | `#10B981` |
| Hover | Emerald 600 | `#059669` |
| Light | Emerald 100 | `#D1FAE5` |
| Dark | Emerald 700 | `#047857` |
