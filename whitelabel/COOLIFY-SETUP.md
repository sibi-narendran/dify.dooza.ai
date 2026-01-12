# 🚀 Deploy Dooza AI with Coolify

Complete guide to deploy studio.dooza.ai on a VPS with Coolify.

---

## Step 1: Get a VPS

### Recommended Providers (pick one):

| Provider | Plan | Price | Link |
|----------|------|-------|------|
| **Hetzner** (best value) | CPX21 (3 vCPU, 4GB RAM) | €7/mo | [hetzner.com/cloud](https://hetzner.com/cloud) |
| **DigitalOcean** | Basic 4GB | $24/mo | [digitalocean.com](https://digitalocean.com) |
| **Vultr** | Cloud Compute 4GB | $24/mo | [vultr.com](https://vultr.com) |
| **Contabo** (cheapest) | VPS S | €6/mo | [contabo.com](https://contabo.com) |

### When creating VPS:
- **OS:** Ubuntu 24.04 LTS
- **Region:** Closest to your users
- **SSH Key:** Add your public key (or use password)

---

## Step 2: Point Your Domain

In your DNS provider (Cloudflare, Namecheap, etc.):

```
Type: A
Name: studio
Value: YOUR_VPS_IP
TTL: Auto
```

Wait 5-10 minutes for DNS to propagate.

**Verify:** `ping studio.dooza.ai` should show your VPS IP.

---

## Step 3: Connect to VPS

```bash
ssh root@YOUR_VPS_IP
```

Or if using SSH key:
```bash
ssh -i ~/.ssh/your_key root@YOUR_VPS_IP
```

---

## Step 4: Install Coolify

Run this single command:

```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

This takes 2-5 minutes. When done, you'll see:

```
Coolify installed successfully!
Access it at: http://YOUR_VPS_IP:8000
```

---

## Step 5: Setup Coolify

### 5.1 Access Coolify Dashboard

Open in browser: `http://YOUR_VPS_IP:8000`

1. Create admin account (first user = admin)
2. Complete the onboarding wizard
3. Select "localhost" as your server (it's already connected)

### 5.2 Add Your Domain to Coolify

1. Go to **Servers** → **localhost** → **Settings**
2. Add your wildcard domain or specific domain
3. Coolify will handle SSL automatically

---

## Step 6: Deploy Dooza AI

### 6.1 Create New Project

1. Click **"New Project"**
2. Name it: `Dooza AI`
3. Click **"Add New Resource"**

### 6.2 Select Source

1. Choose **"Docker Compose"**
2. Select **"GitHub (Public Repository)"**
3. Repository: `https://github.com/sibi-narendran/dify.dooza.ai`
4. Branch: `main`
5. Docker Compose Location: `docker/docker-compose.yaml`

### 6.3 Configure Environment Variables

Click **"Environment Variables"** and add these:

```env
# === REQUIRED - Change these ===
SECRET_KEY=<click-generate-or-paste-random-64-chars>
DB_PASSWORD=<generate-secure-password>
REDIS_PASSWORD=<generate-secure-password>
SANDBOX_API_KEY=<generate-random-key>
CODE_EXECUTION_API_KEY=<same-as-sandbox-key>
PLUGIN_DAEMON_KEY=<generate-random-key>
PLUGIN_DIFY_INNER_API_KEY=<generate-random-key>
WEAVIATE_API_KEY=<generate-random-key>

# === URLs ===
CONSOLE_API_URL=https://studio.dooza.ai
CONSOLE_WEB_URL=https://studio.dooza.ai
SERVICE_API_URL=https://studio.dooza.ai
APP_API_URL=https://studio.dooza.ai
APP_WEB_URL=https://studio.dooza.ai

# === Database ===
DB_USERNAME=postgres
DB_HOST=db_postgres
DB_PORT=5432
DB_DATABASE=dify

# === Redis ===
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0
CELERY_BROKER_URL=redis://:YOUR_REDIS_PASSWORD@redis:6379/1

# === Deployment ===
DEPLOY_ENV=PRODUCTION
DEBUG=false

# === Disable telemetry ===
SCARF_NO_ANALYTICS=true
NEXT_TELEMETRY_DISABLED=1

# === Vector Store ===
VECTOR_STORE=weaviate
WEAVIATE_ENDPOINT=http://weaviate:8080
```

**Generate passwords easily:**
```bash
# Run on your VPS or locally
openssl rand -base64 32
```

### 6.4 Configure Domain

1. Go to **"Domains"** section
2. Add: `studio.dooza.ai`
3. Enable **"Generate SSL"** (Let's Encrypt)

### 6.5 Deploy!

1. Click **"Deploy"**
2. Wait 5-10 minutes for first deployment
3. Watch logs for any errors

---

## Step 7: Verify Deployment

Open https://studio.dooza.ai

You should see:
- ✅ Dooza AI branding
- ✅ Light green theme
- ✅ Your logo
- ✅ SSL padlock

**First user to sign up becomes admin!**

---

## 🔧 Post-Deployment

### View Logs
In Coolify: Click your project → Logs

### Update Dooza AI
1. Push changes to GitHub
2. In Coolify: Click **"Redeploy"**

### Backup Database
```bash
# SSH into VPS
docker exec -t dify-db_postgres-1 pg_dump -U postgres dify > backup.sql
```

---

## ⚠️ Troubleshooting

### "502 Bad Gateway"
- Services still starting, wait 2-3 minutes
- Check logs in Coolify

### "Database connection error"
- Verify DB_PASSWORD matches in all places
- Check CELERY_BROKER_URL has correct password

### "Weaviate not found"
- Add `--profile weaviate` or change VECTOR_STORE to `qdrant`

### Need help?
- Coolify Discord: https://discord.gg/coolify
- Dify Discord: https://discord.gg/dify

---

## 📊 Resource Usage

Expected usage on 4GB VPS:

| Service | RAM | CPU |
|---------|-----|-----|
| Coolify | ~500MB | Low |
| Dify API | ~800MB | Medium |
| Dify Web | ~300MB | Low |
| Dify Worker | ~500MB | Medium |
| PostgreSQL | ~200MB | Low |
| Redis | ~50MB | Low |
| Weaviate | ~500MB | Low |
| **Total** | **~3GB** | - |

You'll have ~1GB headroom on a 4GB VPS. For production with many users, consider 8GB.
