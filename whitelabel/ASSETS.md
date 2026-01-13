# Dooza AI Brand Assets Checklist

## Required Logo Files

Create these files in `whitelabel/web/public/logo/`:

| File | Size | Purpose | Status |
|------|------|---------|--------|
| `logo.svg` | ~48x22 | Main logo (header, auth pages) | ❌ MISSING |
| `logo-monochrome-white.svg` | ~48x22 | Dark mode / inverted | ❌ MISSING |
| `logo-site.png` | 64x64 | Webapp header icon | ❌ MISSING |
| `logo-site-dark.png` | 64x64 | Dark mode webapp icon | ❌ MISSING |
| `logo-embedded-chat-avatar.png` | 40x40 | Chat widget bot avatar | ❌ MISSING |
| `logo-embedded-chat-header.png` | 80x20 | Chat widget header | ❌ MISSING |
| `logo-embedded-chat-header@2x.png` | 160x40 | Chat widget header (retina) | ❌ MISSING |
| `logo-embedded-chat-header@3x.png` | 240x60 | Chat widget header (3x retina) | ❌ MISSING |

## Required Favicon/Icon Files

Create these in `whitelabel/web/public/`:

| File | Size | Purpose | Status |
|------|------|---------|--------|
| `favicon.ico` | 32x32 | Browser tab icon | ✅ EXISTS |
| `favicon-32x32.png` | 32x32 | PNG favicon | ✅ EXISTS |
| `apple-touch-icon.png` | 180x180 | iOS home screen | ✅ EXISTS |
| `icon-72x72.png` | 72x72 | PWA icon | ❌ MISSING |
| `icon-96x96.png` | 96x96 | PWA icon | ❌ MISSING |
| `icon-128x128.png` | 128x128 | PWA icon | ❌ MISSING |
| `icon-144x144.png` | 144x144 | PWA icon | ❌ MISSING |
| `icon-152x152.png` | 152x152 | PWA icon | ❌ MISSING |
| `icon-192x192.png` | 192x192 | PWA icon | ❌ MISSING |
| `icon-256x256.png` | 256x256 | PWA icon | ❌ MISSING |
| `icon-384x384.png` | 384x384 | PWA icon | ❌ MISSING |
| `icon-512x512.png` | 512x512 | PWA icon | ❌ MISSING |

## Design Specs

- **Theme Color:** `#10B981` (Emerald)
- **Background:** White (`#ffffff`)
- **Logo style:** Should match the original aspect ratios

## Quick Generation

If you have a master logo SVG, you can generate all sizes:

```bash
# Using ImageMagick (install first)
convert logo-master.svg -resize 64x64 logo-site.png
convert logo-master.svg -resize 40x40 logo-embedded-chat-avatar.png
# etc.
```

Or use an online tool like https://realfavicongenerator.net/
