# Apply White-Label Configuration
# Run from the repository root: .\whitelabel\apply-whitelabel.ps1
#
# This script:
# 1. Copies all brand assets (logos, favicons, icons) to production
# 2. Runs the text rebrand (Dify -> Dooza)
# 3. Optionally builds Docker images and deploys

param(
    [switch]$Build,       # Build custom Docker images
    [switch]$Deploy,      # Deploy with docker compose
    [switch]$AssetsOnly,  # Only sync assets, skip rebrand
    [switch]$DryRun       # Show what would be done without doing it
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$WhitelabelDir = $PSScriptRoot
$DockerDir = Join-Path $RepoRoot "docker"

Write-Host ""
Write-Host "[WHITELABEL] Dooza AI White-Label Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Required assets checklist
$RequiredAssets = @(
    @{ Path = "web/public/logo/logo.svg"; Desc = "Main logo" },
    @{ Path = "web/public/logo/logo-monochrome-white.svg"; Desc = "Dark mode logo" },
    @{ Path = "web/public/logo/logo-site.png"; Desc = "Site header icon" },
    @{ Path = "web/public/favicon.ico"; Desc = "Favicon" }
)

# Check for missing assets
Write-Host ""
Write-Host "[CHECK] Required assets:" -ForegroundColor Yellow
$MissingAssets = @()
foreach ($asset in $RequiredAssets) {
    $assetPath = Join-Path $WhitelabelDir $asset.Path
    if (Test-Path $assetPath) {
        Write-Host "   [OK] $($asset.Desc)" -ForegroundColor Green
    } else {
        Write-Host "   [MISSING] $($asset.Desc) - $($asset.Path)" -ForegroundColor Red
        $MissingAssets += $asset.Path
    }
}

if ($MissingAssets.Count -gt 0) {
    Write-Host ""
    Write-Host "[WARN] Some assets are missing. See whitelabel/ASSETS.md for specs." -ForegroundColor Yellow
}

# Function to sync all whitelabel assets
function Sync-WhitelabelAssets {
    Write-Host ""
    Write-Host "[ASSETS] Syncing brand assets..." -ForegroundColor Green
    
    $copied = 0
    
    # Sync logo folder
    $sourceLogo = Join-Path $WhitelabelDir "web/public/logo"
    $targetLogo = Join-Path $RepoRoot "web/public/logo"
    
    if (Test-Path $sourceLogo) {
        Get-ChildItem $sourceLogo -File | ForEach-Object {
            $target = Join-Path $targetLogo $_.Name
            if ($DryRun) {
                Write-Host "   [DRY RUN] Would copy: logo/$($_.Name)" -ForegroundColor Gray
            } else {
                Copy-Item $_.FullName $target -Force
                Write-Host "   [OK] logo/$($_.Name)" -ForegroundColor Gray
            }
            $script:copied++
        }
    }
    
    # Sync root public files (favicon, icons, manifest)
    $sourcePublic = Join-Path $WhitelabelDir "web/public"
    $targetPublic = Join-Path $RepoRoot "web/public"
    
    $rootFiles = @("favicon.ico", "favicon-32x32.png", "apple-touch-icon.png", "manifest.json")
    foreach ($file in $rootFiles) {
        $src = Join-Path $sourcePublic $file
        $dst = Join-Path $targetPublic $file
        if (Test-Path $src) {
            if ($DryRun) {
                Write-Host "   [DRY RUN] Would copy: $file" -ForegroundColor Gray
            } else {
                Copy-Item $src $dst -Force
                Write-Host "   [OK] $file" -ForegroundColor Gray
            }
            $script:copied++
        }
    }
    
    # Sync PWA icons (icon-*.png)
    Get-ChildItem $sourcePublic -Filter "icon-*.png" -ErrorAction SilentlyContinue | ForEach-Object {
        $dst = Join-Path $targetPublic $_.Name
        if ($DryRun) {
            Write-Host "   [DRY RUN] Would copy: $($_.Name)" -ForegroundColor Gray
        } else {
            Copy-Item $_.FullName $dst -Force
            Write-Host "   [OK] $($_.Name)" -ForegroundColor Gray
        }
        $script:copied++
    }
    
    Write-Host "   [STATS] $copied files synced" -ForegroundColor Cyan
}

# Function to run text rebrand
function Invoke-Rebrand {
    Write-Host ""
    Write-Host "[REBRAND] Running text rebrand (Dify -> Dooza)..." -ForegroundColor Green
    
    $rebrandScript = Join-Path $WhitelabelDir "rebrand.ps1"
    if (Test-Path $rebrandScript) {
        if ($DryRun) {
            & $rebrandScript -DryRun
        } else {
            & $rebrandScript
        }
    } else {
        Write-Host "   [WARN] rebrand.ps1 not found, skipping" -ForegroundColor Yellow
    }
}

# Function to deploy with Docker
function Deploy-Whitelabel {
    Write-Host ""
    Write-Host "[DOCKER] Deploying with Docker Compose..." -ForegroundColor Green
    
    Push-Location $DockerDir
    try {
        $overrideFile = Join-Path $WhitelabelDir "docker/docker-compose.override.yml"
        if (Test-Path $overrideFile) {
            $composeCmd = "docker compose -f docker-compose.yaml -f `"$overrideFile`""
        } else {
            $composeCmd = "docker compose"
        }
        
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
    Write-Host ""
    Write-Host "[DOCKER] Building custom Docker images..." -ForegroundColor Green
    
    $dockerfilePath = Join-Path $WhitelabelDir "docker/Dockerfile.web"
    
    if (-not (Test-Path $dockerfilePath)) {
        Write-Host "   Creating Dockerfile.web..." -ForegroundColor Gray
        
        $dockerfileContent = @"
# Dooza AI Custom Web Image
FROM langgenius/dify-web:latest

# Copy custom assets
COPY whitelabel/web/public/logo /app/web/public/logo
COPY whitelabel/web/public/favicon.ico /app/web/public/favicon.ico
COPY whitelabel/web/public/apple-touch-icon.png /app/web/public/apple-touch-icon.png
COPY whitelabel/web/public/manifest.json /app/web/public/manifest.json
"@
        
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path (Split-Path $dockerfilePath) -Force | Out-Null
            Set-Content -Path $dockerfilePath -Value $dockerfileContent
        }
    }
    
    if (-not $DryRun) {
        Push-Location $RepoRoot
        try {
            docker build -f "$dockerfilePath" -t dooza/dify-web:latest .
            Write-Host "   [OK] Built: dooza/dify-web:latest" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
}

# Main execution
Sync-WhitelabelAssets

if (-not $AssetsOnly) {
    Invoke-Rebrand
}

if ($Build) {
    Build-WhitelabelImages
}

if ($Deploy) {
    Deploy-Whitelabel
}

Write-Host ""
Write-Host "[DONE] White-label setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Add missing logo files to whitelabel/web/public/logo/"
Write-Host "  2. Run: .\whitelabel\apply-whitelabel.ps1 -Deploy"
Write-Host "  3. After upstream updates: .\whitelabel\apply-whitelabel.ps1"
Write-Host ""
