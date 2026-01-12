# Apply White-Label Configuration
# Run from the repository root: .\whitelabel\apply-whitelabel.ps1

param(
    [switch]$Build,      # Build custom Docker images
    [switch]$Deploy,     # Deploy with docker compose
    [switch]$DryRun      # Show what would be done without doing it
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$WhitelabelDir = $PSScriptRoot
$DockerDir = Join-Path $RepoRoot "docker"

Write-Host "🏷️  Dooza AI White-Label Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Check if required files exist
$RequiredAssets = @(
    "web/public/logo/logo.svg"
)

$MissingAssets = @()
foreach ($asset in $RequiredAssets) {
    $assetPath = Join-Path $WhitelabelDir $asset
    if (-not (Test-Path $assetPath)) {
        $MissingAssets += $asset
    }
}

if ($MissingAssets.Count -gt 0) {
    Write-Host "`n⚠️  Missing required assets:" -ForegroundColor Yellow
    foreach ($missing in $MissingAssets) {
        Write-Host "   - $missing" -ForegroundColor Yellow
    }
    Write-Host "`nPlease create your brand assets before deploying." -ForegroundColor Yellow
    Write-Host "See whitelabel/README.md for asset specifications.`n" -ForegroundColor Gray
}

# Function to sync whitelabel assets
function Sync-WhitelabelAssets {
    Write-Host "`n📁 Syncing white-label assets..." -ForegroundColor Green
    
    $sourceLogo = Join-Path $WhitelabelDir "web/public/logo"
    $targetLogo = Join-Path $RepoRoot "web/public/logo"
    
    if (Test-Path $sourceLogo) {
        $files = Get-ChildItem $sourceLogo -File
        foreach ($file in $files) {
            $target = Join-Path $targetLogo $file.Name
            if ($DryRun) {
                Write-Host "   [DRY RUN] Would copy: $($file.Name)" -ForegroundColor Gray
            } else {
                Copy-Item $file.FullName $target -Force
                Write-Host "   ✓ Copied: $($file.Name)" -ForegroundColor Gray
            }
        }
    }
    
    # Copy manifest.json if exists
    $manifestSrc = Join-Path $WhitelabelDir "web/public/manifest.json"
    $manifestDst = Join-Path $RepoRoot "web/public/manifest.json"
    if (Test-Path $manifestSrc) {
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would copy: manifest.json" -ForegroundColor Gray
        } else {
            Copy-Item $manifestSrc $manifestDst -Force
            Write-Host "   ✓ Copied: manifest.json" -ForegroundColor Gray
        }
    }
}

# Function to deploy with Docker
function Deploy-Whitelabel {
    Write-Host "`n🐳 Deploying with Docker Compose..." -ForegroundColor Green
    
    Push-Location $DockerDir
    try {
        $composeCmd = "docker compose -f docker-compose.yaml -f ../whitelabel/docker/docker-compose.override.yml"
        
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would run: $composeCmd up -d" -ForegroundColor Gray
        } else {
            Write-Host "   Running: $composeCmd up -d" -ForegroundColor Gray
            Invoke-Expression "$composeCmd up -d"
        }
    } finally {
        Pop-Location
    }
}

# Function to build custom images
function Build-WhitelabelImages {
    Write-Host "`n🔨 Building custom Docker images..." -ForegroundColor Green
    
    # Check if Dockerfile exists
    $dockerfilePath = Join-Path $WhitelabelDir "docker/Dockerfile.web"
    
    if (-not (Test-Path $dockerfilePath)) {
        Write-Host "   Creating Dockerfile.web..." -ForegroundColor Gray
        
        $dockerfileContent = @"
# Dooza AI Custom Web Image
FROM langgenius/dify-web:1.11.2

# Copy custom assets
COPY whitelabel/web/public/logo /app/web/public/logo
COPY whitelabel/web/public/favicon.ico /app/web/public/favicon.ico
COPY whitelabel/web/public/manifest.json /app/web/public/manifest.json
"@
        
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would create: $dockerfilePath" -ForegroundColor Gray
        } else {
            Set-Content -Path $dockerfilePath -Value $dockerfileContent
        }
    }
    
    if (-not $DryRun) {
        Push-Location $RepoRoot
        try {
            docker build -f "$dockerfilePath" -t dooza/dify-web:latest .
            Write-Host "   ✓ Built: dooza/dify-web:latest" -ForegroundColor Gray
        } finally {
            Pop-Location
        }
    }
}

# Main execution
if ($Build -or $Deploy -or (-not $Build -and -not $Deploy)) {
    Sync-WhitelabelAssets
}

if ($Build) {
    Build-WhitelabelImages
}

if ($Deploy) {
    Deploy-Whitelabel
}

Write-Host "`n✅ White-label setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Add your logo files to whitelabel/web/public/logo/"
Write-Host "  2. Create whitelabel/web/public/manifest.json"
Write-Host "  3. Configure docker/.env with your settings"
Write-Host "  4. Run: .\whitelabel\apply-whitelabel.ps1 -Deploy"
Write-Host ""
