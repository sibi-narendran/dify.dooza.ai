# Rebrand Dify to Dooza
# Run from repository root: .\whitelabel\rebrand.ps1
# 
# This script replaces "Dify" (case-sensitive) with "Dooza" in:
# - All i18n translation files (22 languages)
# - Frontend component files with hardcoded text
#
# Safe to re-run after pulling upstream updates.

param(
    [switch]$DryRun,        # Show what would be changed without making changes
    [switch]$I18nOnly,      # Only process i18n files
    [switch]$ComponentsOnly # Only process component files
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$WebDir = Join-Path $RepoRoot "web"

Write-Host ""
Write-Host "[REBRAND] Dooza AI Rebranding Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$totalChanges = 0

# Function to replace text in file
function Replace-InFile {
    param(
        [string]$FilePath,
        [string]$Find,
        [string]$Replace
    )
    
    if (-not (Test-Path $FilePath)) {
        return 0
    }
    
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Case-sensitive replace
    $newContent = $content -creplace $Find, $Replace
    
    if ($newContent -ne $originalContent) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would update: $FilePath" -ForegroundColor Gray
        }
        else {
            Set-Content -Path $FilePath -Value $newContent -NoNewline -Encoding UTF8
        }
        return 1
    }
    return 0
}

# Process i18n files
function Process-I18nFiles {
    Write-Host "[i18n] Processing translation files..." -ForegroundColor Green
    
    $i18nDir = Join-Path $WebDir "i18n"
    $changedFiles = 0
    
    Get-ChildItem -Path $i18nDir -Recurse -Filter "*.json" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Case-SENSITIVE replace: only "Dify" with capital D
        # This avoids breaking words like "modify", "codify", etc.
        $newContent = $content -creplace 'Dify', 'Dooza'
        
        if ($newContent -ne $originalContent) {
            $changedFiles++
            $relativePath = $_.FullName.Substring($RepoRoot.Length + 1)
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would update: $relativePath" -ForegroundColor Gray
            }
            else {
                Set-Content -Path $_.FullName -Value $newContent -NoNewline -Encoding UTF8
                Write-Host "  [OK] Updated: $relativePath" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host "  [STATS] i18n files changed: $changedFiles" -ForegroundColor Cyan
    return $changedFiles
}

# Process component files
function Process-ComponentFiles {
    Write-Host ""
    Write-Host "[Components] Processing component files..." -ForegroundColor Green
    
    $changedFiles = 0
    
    # Update logo alt text
    $logoFile = Join-Path $WebDir "app/components/base/logo/dify-logo.tsx"
    $changedFiles += Replace-InFile -FilePath $logoFile -Find 'alt="Dify logo"' -Replace 'alt="Dooza logo"'
    
    # Update icon display name
    $iconFile = Join-Path $WebDir "app/components/base/icons/src/public/common/Dify.tsx"
    $changedFiles += Replace-InFile -FilePath $iconFile -Find "displayName = 'Dify'" -Replace "displayName = 'Dooza'"
    
    Write-Host "  [STATS] Component files changed: $changedFiles" -ForegroundColor Cyan
    return $changedFiles
}

# Main execution
if (-not $ComponentsOnly) {
    $totalChanges += Process-I18nFiles
}

if (-not $I18nOnly) {
    $totalChanges += Process-ComponentFiles
}

Write-Host ""
Write-Host "[DONE] Rebranding complete!" -ForegroundColor Green
Write-Host "        Total files modified: $totalChanges" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host ""
    Write-Host "[NOTE] This was a dry run. No files were actually modified." -ForegroundColor Yellow
    Write-Host "       Run without -DryRun to apply changes." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[TIPS]" -ForegroundColor Cyan
Write-Host "  - Re-run this script after pulling upstream updates"
Write-Host "  - Check the changes with: git diff"
Write-Host "  - Commit the changes to preserve your rebranding"
Write-Host ""
