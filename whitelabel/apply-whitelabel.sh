#!/bin/bash
# Apply White-Label Configuration
# Run from the repository root: ./whitelabel/apply-whitelabel.sh

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WHITELABEL_DIR="$REPO_ROOT/whitelabel"
DOCKER_DIR="$REPO_ROOT/docker"

BUILD=false
DEPLOY=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD=true
            shift
            ;;
        --deploy)
            DEPLOY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🏷️  Dooza AI White-Label Setup"
echo "================================"

# Check for required assets
MISSING_ASSETS=()
if [ ! -f "$WHITELABEL_DIR/web/public/logo/logo.svg" ]; then
    MISSING_ASSETS+=("web/public/logo/logo.svg")
fi

if [ ${#MISSING_ASSETS[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Missing required assets:"
    for asset in "${MISSING_ASSETS[@]}"; do
        echo "   - $asset"
    done
    echo ""
    echo "Please create your brand assets before deploying."
    echo "See whitelabel/README.md for asset specifications."
fi

# Sync assets
sync_assets() {
    echo ""
    echo "📁 Syncing white-label assets..."
    
    SOURCE_LOGO="$WHITELABEL_DIR/web/public/logo"
    TARGET_LOGO="$REPO_ROOT/web/public/logo"
    
    if [ -d "$SOURCE_LOGO" ]; then
        for file in "$SOURCE_LOGO"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                if [ "$DRY_RUN" = true ]; then
                    echo "   [DRY RUN] Would copy: $filename"
                else
                    cp "$file" "$TARGET_LOGO/$filename"
                    echo "   ✓ Copied: $filename"
                fi
            fi
        done
    fi
    
    # Copy manifest.json if exists
    if [ -f "$WHITELABEL_DIR/web/public/manifest.json" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "   [DRY RUN] Would copy: manifest.json"
        else
            cp "$WHITELABEL_DIR/web/public/manifest.json" "$REPO_ROOT/web/public/manifest.json"
            echo "   ✓ Copied: manifest.json"
        fi
    fi
}

# Deploy with Docker
deploy_whitelabel() {
    echo ""
    echo "🐳 Deploying with Docker Compose..."
    
    cd "$DOCKER_DIR"
    
    COMPOSE_CMD="docker compose -f docker-compose.yaml -f ../whitelabel/docker/docker-compose.override.yml"
    
    if [ "$DRY_RUN" = true ]; then
        echo "   [DRY RUN] Would run: $COMPOSE_CMD up -d"
    else
        echo "   Running: $COMPOSE_CMD up -d"
        $COMPOSE_CMD up -d
    fi
}

# Build custom images
build_images() {
    echo ""
    echo "🔨 Building custom Docker images..."
    
    DOCKERFILE="$WHITELABEL_DIR/docker/Dockerfile.web"
    
    if [ ! -f "$DOCKERFILE" ]; then
        echo "   Creating Dockerfile.web..."
        
        cat > "$DOCKERFILE" << 'EOF'
# Dooza AI Custom Web Image
FROM langgenius/dify-web:1.11.2

# Copy custom assets
COPY whitelabel/web/public/logo /app/web/public/logo
COPY whitelabel/web/public/favicon.ico /app/web/public/favicon.ico
COPY whitelabel/web/public/manifest.json /app/web/public/manifest.json
EOF
    fi
    
    if [ "$DRY_RUN" = false ]; then
        cd "$REPO_ROOT"
        docker build -f "$DOCKERFILE" -t dooza/dify-web:latest .
        echo "   ✓ Built: dooza/dify-web:latest"
    fi
}

# Main execution
if [ "$BUILD" = true ] || [ "$DEPLOY" = true ] || ([ "$BUILD" = false ] && [ "$DEPLOY" = false ]); then
    sync_assets
fi

if [ "$BUILD" = true ]; then
    build_images
fi

if [ "$DEPLOY" = true ]; then
    deploy_whitelabel
fi

echo ""
echo "✅ White-label setup complete!"
echo ""
echo "Next steps:"
echo "  1. Add your logo files to whitelabel/web/public/logo/"
echo "  2. Create whitelabel/web/public/manifest.json"
echo "  3. Configure docker/.env with your settings"
echo "  4. Run: ./whitelabel/apply-whitelabel.sh --deploy"
echo ""
