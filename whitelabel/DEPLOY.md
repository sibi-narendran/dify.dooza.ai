# 🚀 Deploy Dooza AI to studio.dooza.ai

## Prerequisites

- A server (VPS) with:
  - Ubuntu 22.04+ or similar
  - 4GB+ RAM (8GB recommended)
  - 50GB+ storage
  - Docker & Docker Compose installed
- Domain `studio.dooza.ai` pointing to your server IP

## Step 1: Server Setup

SSH into your server:

```bash
ssh root@your-server-ip
```

Install Docker (if not installed):

```bash
curl -fsSL https://get.docker.com | sh
```

## Step 2: Clone Repository

```bash
cd /opt
git clone https://github.com/sibi-narendran/dify.dooza.ai.git dooza
cd dooza
```

## Step 3: Configure Environment

```bash
# Copy the production template
cp whitelabel/docker/production.env docker/.env

# Generate secure keys
SECRET_KEY=$(openssl rand -base64 48)
DB_PASSWORD=$(openssl rand -base64 24)
REDIS_PASSWORD=$(openssl rand -base64 24)
SANDBOX_KEY=$(openssl rand -base64 32)
PLUGIN_KEY=$(openssl rand -base64 48)

# Update the .env file with generated keys
sed -i "s|CHANGE_ME_generate_with_openssl_rand_base64_48|$SECRET_KEY|g" docker/.env
sed -i "s|CHANGE_ME_secure_db_password|$DB_PASSWORD|g" docker/.env
sed -i "s|CHANGE_ME_secure_redis_password|$REDIS_PASSWORD|g" docker/.env
sed -i "s|CHANGE_ME_weaviate_key|$(openssl rand -base64 32)|g" docker/.env
sed -i "s|CHANGE_ME_sandbox_key|$SANDBOX_KEY|g" docker/.env
sed -i "s|CHANGE_ME_plugin_daemon_key|$PLUGIN_KEY|g" docker/.env
sed -i "s|CHANGE_ME_plugin_inner_key|$(openssl rand -base64 48)|g" docker/.env

# Update your email for SSL
sed -i "s|your-email@dooza.ai|YOUR_ACTUAL_EMAIL|g" docker/.env
```

## Step 4: Start Services

```bash
cd docker

# Start with PostgreSQL profile (recommended)
docker compose --profile postgresql up -d

# Or start with weaviate vector store too:
docker compose --profile postgresql --profile weaviate up -d
```

## Step 5: Get SSL Certificate

After services are running:

```bash
# Run certbot to get Let's Encrypt certificate
docker compose --profile certbot up certbot

# Restart nginx to apply certificate
docker compose restart nginx
```

## Step 6: Access Your Instance

Open https://studio.dooza.ai in your browser!

First user to sign up becomes the admin.

---

## 🔧 Management Commands

```bash
# View logs
docker compose logs -f

# Restart all services
docker compose restart

# Stop all services
docker compose down

# Update to latest
git pull origin main
docker compose pull
docker compose up -d
```

## 🔄 Update from Upstream Dify

```bash
git fetch upstream
git merge upstream/main
docker compose pull
docker compose up -d
```

---

## Alternative: Deploy with Cloudflare Tunnel (No Port Opening)

If you can't open ports 80/443:

1. Install cloudflared on your server
2. Create a tunnel: `cloudflared tunnel create dooza`
3. Route tunnel to localhost:80
4. Set DNS in Cloudflare dashboard

---

## Troubleshooting

**Services won't start?**
```bash
docker compose logs api
docker compose logs web
```

**Database issues?**
```bash
docker compose exec db_postgres psql -U postgres -d dify
```

**Reset everything?**
```bash
docker compose down -v  # WARNING: Deletes all data!
docker compose up -d
```
