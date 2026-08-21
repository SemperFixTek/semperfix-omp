param(
    [string]$SourceRoot = "$PSScriptRoot",
    [string]$ModuleName = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.0"
)

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan
Write-Host "Module: $ModuleName  Version: $ModuleVersion" -ForegroundColor Cyan

# Resolve source paths
$moduleSource = Join-Path $SourceRoot $ModuleName
$versionSource = Join-Path $moduleSource $ModuleVersion

if (-not (Test-Path $versionSource)) {
    Write-Error "Source module version folder not found: $versionSource"
    exit 1
}

# Resolve target module path
$modulesRoot = Join-Path $HOME "Documents\PowerShell\Modules"
$moduleTargetRoot = Join-Path $modulesRoot $ModuleName
$moduleTargetVersion = Join-Path $moduleTargetRoot $ModuleVersion

Write-Host "Installing module to: $moduleTargetVersion" -ForegroundColor Yellow

# Ensure root + version folders exist
New-Item -Path $moduleTargetRoot -ItemType Directory -Force | Out-Null
New-Item -Path $moduleTargetVersion -ItemType Directory -Force | Out-Null

# Copy module version folder
Copy-Item -Path (Join-Path $versionSource "*") -Destination $moduleTargetVersion -Recurse -Force

# Verify manifest
$manifestPath = Join-Path $moduleTargetVersion "$ModuleName.psd1"
if (-not (Test-Path $manifestPath)) {
    Write-Error "Manifest not found after copy: $manifestPath"
    exit 1
}

$manifest = Test-ModuleManifest $manifestPath
Write-Host "Module manifest validated: $($manifest.ModuleName) $($manifest.Version)" -ForegroundColor Green

# Import module to confirm
Import-Module $ModuleName -Force -ErrorAction Stop
Write-Host "Module imported successfully." -ForegroundColor Green

# Optional: install WSL loader if present
$wslLoaderSource = Join-Path $SourceRoot "wsl\poshloader.sh"
if (Test-Path $wslLoaderSource) {
    Write-Host "WSL loader found, installing..." -ForegroundColor Yellow

    $wslHome = "$HOME"
    $wslLoaderTarget = Join-Path $wslHome ".poshloader"

    Copy-Item -Path $wslLoaderSource -Destination $wslLoaderTarget -Force
    Write-Host "WSL loader installed to: $wslLoaderTarget" -ForegroundColor Green
} else {
    Write-Host "No WSL loader found in repo (wsl\poshloader.sh). Skipping." -ForegroundColor DarkYellow
}

Write-Host "SemperFix-OMP installation complete." -ForegroundColor Cyan
