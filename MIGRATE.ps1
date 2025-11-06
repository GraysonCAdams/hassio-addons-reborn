# PowerShell Migration Script for Guacamole Client WiFi Addon
# Migrates from multi-addon structure to single-addon repository
#
# IMPORTANT: This script moves files from guacamole-client/ to repository root
# and removes all other addon folders. Run from repository root.
#
# Usage: .\MIGRATE.ps1

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Guacamole Client WiFi - Migration Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verify we're in the correct directory
if (-not (Test-Path "guacamole-client")) {
    Write-Host "ERROR: guacamole-client directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the repository root." -ForegroundColor Red
    exit 1
}

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be modified`n" -ForegroundColor Yellow
}

# Step 1: Backup check
Write-Host "[1/6] Backup Check" -ForegroundColor Green
Write-Host "Before proceeding, ensure you have:"
Write-Host "  - Committed all changes (git status should be clean)"
Write-Host "  - Or created a backup of this directory"
Write-Host ""
$continue = Read-Host "Continue? (y/n)"
if ($continue -ne "y") {
    Write-Host "Migration cancelled." -ForegroundColor Yellow
    exit 0
}

# Step 2: List folders to remove
Write-Host "`n[2/6] Folders to Remove" -ForegroundColor Green
$foldersToRemove = @(
    "baikal",
    "guacamole",
    "guacamole-server",
    "hpessa",
    "jdownloader2",
    "mediaelch",
    "oscam",
    "ps3netsrv",
    "tvheadend"
)

foreach ($folder in $foldersToRemove) {
    if (Test-Path $folder) {
        Write-Host "  ✓ Found: $folder" -ForegroundColor Yellow
    } else {
        Write-Host "  - Not found: $folder (already removed)" -ForegroundColor Gray
    }
}

# Step 3: Move files from guacamole-client/ to root
Write-Host "`n[3/6] Moving Files to Root" -ForegroundColor Green

$itemsToMove = @(
    "Dockerfile",
    "config.json",
    "build.yaml",
    "rootfs",
    "README.md",
    "DOCS.md",
    "QUICKSTART.md",
    "SETUP-GUIDE.md",
    "QUICK-REF.md",
    "SUMMARY.md",
    "ARCHITECTURE.md",
    "RASPBERRY-PI.md",
    "WIFI-OPTIMIZATION.md",
    "PERFORMANCE.md",
    "BUILD.md",
    "CHANGELOG.md",
    "RESTRUCTURE.md"
)

foreach ($item in $itemsToMove) {
    $source = Join-Path "guacamole-client" $item
    if (Test-Path $source) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would move: $item" -ForegroundColor Cyan
        } else {
            Write-Host "  Moving: $item" -ForegroundColor White
            Move-Item -Path $source -Destination "." -Force
        }
    } else {
        Write-Host "  - Skipping: $item (not found)" -ForegroundColor Gray
    }
}

# Step 4: Handle workflow file
Write-Host "`n[4/6] Setting Up Workflow" -ForegroundColor Green

$oldWorkflow = ".github\workflows\build-guacamole-client.yml"
$newWorkflowSource = "guacamole-client\.github\workflows\build.yml"
$newWorkflowDest = ".github\workflows\build.yml"

if (-not $DryRun) {
    # Create .github/workflows if it doesn't exist
    if (-not (Test-Path ".github\workflows")) {
        New-Item -ItemType Directory -Path ".github\workflows" -Force | Out-Null
    }
}

if (Test-Path $newWorkflowSource) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would copy: build.yml to .github/workflows/" -ForegroundColor Cyan
    } else {
        Write-Host "  Copying: build.yml to .github/workflows/" -ForegroundColor White
        Copy-Item -Path $newWorkflowSource -Destination $newWorkflowDest -Force
    }
}

if (Test-Path $oldWorkflow) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would remove: old workflow (build-guacamole-client.yml)" -ForegroundColor Cyan
    } else {
        Write-Host "  Removing: old workflow (build-guacamole-client.yml)" -ForegroundColor Yellow
        Remove-Item -Path $oldWorkflow -Force
    }
}

# Step 5: Remove old addon folders
Write-Host "`n[5/6] Removing Old Addon Folders" -ForegroundColor Green

foreach ($folder in $foldersToRemove) {
    if (Test-Path $folder) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would remove: $folder" -ForegroundColor Cyan
        } else {
            Write-Host "  Removing: $folder" -ForegroundColor Yellow
            Remove-Item -Path $folder -Recurse -Force
        }
    }
}

# Step 6: Remove guacamole-client folder
Write-Host "`n[6/6] Cleaning Up" -ForegroundColor Green

if (Test-Path "guacamole-client") {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would remove: guacamole-client/ folder" -ForegroundColor Cyan
    } else {
        Write-Host "  Removing: guacamole-client/ folder (now empty)" -ForegroundColor Yellow
        Remove-Item -Path "guacamole-client" -Recurse -Force
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Migration Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "This was a DRY RUN. No files were modified." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual migration:`n" -ForegroundColor Yellow
    Write-Host "  .\MIGRATE.ps1`n" -ForegroundColor White
} else {
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review changes: git status"
    Write-Host "  2. Test build locally (optional):"
    Write-Host "       docker build -t test-guac ."
    Write-Host "  3. Commit changes:"
    Write-Host "       git add -A"
    Write-Host "       git commit -m 'Restructure to single-addon repository'"
    Write-Host "  4. Push to new repository:"
    Write-Host "       git remote set-url origin https://github.com/graysoncadams/hassio-guacamole-client"
    Write-Host "       git push -u origin main"
    Write-Host "  5. Verify GitHub Actions build succeeds"
    Write-Host "  6. Make GHCR package public (Settings > Packages)"
    Write-Host ""
    Write-Host "See RESTRUCTURE.md for detailed next steps." -ForegroundColor Yellow
}

Write-Host ""
