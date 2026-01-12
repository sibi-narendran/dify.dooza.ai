#!/bin/bash
# Quick Deploy Script for Dooza AI
# Run on your server: curl -sSL https://raw.githubusercontent.com/sibi-narendran/dify.dooza.ai/main/whitelabel/deploy.sh | bash

set -e

DOMAIN="${DOMAIN:-studio.dooza.ai}"
EMAIL="${EMAIL:-admin@dooza.ai}"
INSTALL_DIR="${INSTALL_DIR:-/opt/dooza}"

echo "🚀 Deploying Dooza AI to $DOMAIN"
echo "================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
    echo "📂 Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo "📂 Cloning repository..."
    git clone https://github.com/sibi-narendran/dify.dooza.ai.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Setup environment
echo "⚙️  Configuring environment..."
cp whitelabel/docker/production.env docker/.env

# Generate secure keys
SECRET_KEY=$(openssl rand -base64 48)
DB_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)
REDIS_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)
WEAVIATE_KEY=$(openssl rand -base64 32 | tr -d '/+=' | head -c 32)
SANDBOX_KEY=$(openssl rand -base64 32 | tr -d '/+=' | head -c 32)
PLUGIN_KEY=$(openssl rand -base64 48 | tr -d '/+=' | head -c 48)
INNER_KEY=$(openssl rand -base64 48 | tr -d '/+=' | head -c 48)

# Update .env with actual values
sed -i "s|CHANGE_ME_generate_with_openssl_rand_base64_48|$SECRET_KEY|g" docker/.env
sed -i "s|CHANGE_ME_secure_db_password|$DB_PASSWORD|g" docker/.env
sed -i "s|CHANGE_ME_secure_redis_password|$REDIS_PASSWORD|g" docker/.env
sed -i "s|CHANGE_ME_weaviate_key|$WEAVIATE_KEY|g" docker/.env
sed -i "s|CHANGE_ME_sandbox_key|$SANDBOX_KEY|g" docker/.env
sed -i "s|CHANGE_ME_plugin_daemon_key|$PLUGIN_KEY|g" docker/.env
sed -i "s|CHANGE_ME_plugin_inner_key|$INNER_KEY|g" docker/.env
sed -i "s|your-email@dooza.ai|$EMAIL|g" docker/.env
sed -i "s|studio.dooza.ai|$DOMAIN|g" docker/.env

# Fix Redis password in CELERY_BROKER_URL
sed -i "s|redis://:CHANGE_ME_secure_redis_password@|redis://:$REDIS_PASSWORD@|g" docker/.env

# Start services
echo "🐳 Starting services..."
cd docker
docker compose --profile postgresql up -d

echo ""
echo "✅ Dooza AI deployed successfully!"
echo ""
echo "🌐 Access your instance at: https://$DOMAIN"
echo "   (SSL will be configured automatically)"
echo ""
echo "📋 Next steps:"
echo "   1. Make sure DNS for $DOMAIN points to this server"
echo "   2. Wait 2-3 minutes for services to initialize"
echo "   3. Open https://$DOMAIN and create your admin account"
echo ""
echo "📝 Logs: docker compose logs -f"
echo "🔧 Manage: cd $INSTALL_DIR/docker && docker compose [command]"
