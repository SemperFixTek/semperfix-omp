# Elevation check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Elevating installer..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    exit
}

param(
    [string]$ModuleName = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.0"
)

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan
Write-Host "Module: $ModuleName  Version: $ModuleVersion" -ForegroundColor Cyan

# Detect repo root (installer folder is inside /installer)
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Module source is in /modules/SemperFix.OMP/<version>
$moduleSource = Join-Path $RepoRoot "modules\$ModuleName"
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

Write-Host "[Fonts] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

$fontSource = Join-Path $RepoRoot "windows\fonts"
$fontTarget = "$env:WINDIR\Fonts"

if (-not (Test-Path $fontSource)) {
    Write-Error "Font source folder not found: $fontSource"
    exit 1
}

###
Write-Host "[Fonts] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

$fontSource = Join-Path $RepoRoot "windows\fonts"
$fontTarget = "$env:WINDIR\Fonts"

if (-not (Test-Path $fontSource)) {
    Write-Error "Font source folder not found: $fontSource"
    exit 1
}

# Remove old JetBrainsMono fonts
Write-Host "[Fonts] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
Get-ChildItem $fontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } | ForEach-Object {
    Write-Host "Removing: $($_.Name)"
    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
}

# COM registration
$Shell = New-Object -ComObject Shell.Application
$FontsFolder = $Shell.NameSpace($fontTarget)

Get-ChildItem -Path $fontSource -Filter *.ttf | ForEach-Object {
    $fontFile = $_.FullName
    Write-Host "Installing font: $($_.Name)"

    Copy-Item $fontFile $fontTarget -Force
    $FontsFolder.CopyHere($fontFile, 0x10)
}

Write-Host "[Fonts] Refreshing DirectWrite cache..." -ForegroundColor Yellow
try {
    rundll32.exe "C:\Windows\System32\fntcache.dll",FontCache
    Write-Host "DirectWrite cache refreshed." -ForegroundColor Green
} catch {
    Write-Warning "Could not refresh DirectWrite cache. Windows will refresh automatically."
}

Write-Host "[Fonts] Verifying installation..." -ForegroundColor Yellow
$installed = Get-ChildItem $fontTarget | Select-String "JetBrainsMono"
if ($installed) {
    Write-Host "JetBrainsMono Nerd Font installed successfully." -ForegroundColor Green
} else {
    Write-Warning "JetBrainsMono Nerd Font not detected. Installation may have failed."
}

# Optional: install WSL loader if present
$wslLoaderSource = Join-Path $RepoRoot "wsl\poshloader.sh"

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
