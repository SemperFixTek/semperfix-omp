param(
    [string]$ModuleName    = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.1",
    [switch]$Force,
    [switch]$SkipFonts
)
# Requires -Version 7.0
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Restarting installer under PowerShell 7..." -ForegroundColor Yellow
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($args -join ' ')"
    exit
}
Write-Host "SemperFix-OMP Installer"
Write-Host "Module: $ModuleName  Version: $ModuleVersion"

# Elevation
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($args -join ' ')"
    exit
}

# RepoRoot
$RepoRoot = Split-Path $PSscriptRoot -Parent
Write-Host "RepoRoot: $RepoRoot"

@{ RepoRoot = $RepoRoot } | ConvertTo-Json | Set-Content "$env:USERPROFILE\.semperfix-omp.json"

# Module source
$ModuleSourceRoot = Join-Path $RepoRoot "modules\$ModuleName"
$VersionSource    = Join-Path $ModuleSourceRoot $ModuleVersion

Write-Host "ModuleSource: $ModuleSourceRoot"
Write-Host "VersionSource: $VersionSource"

if (-not (Test-Path $VersionSource)) {
    Write-Error "Module version folder not found: $VersionSource"
    exit 1
}

# Target
$TargetRoot    = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\$ModuleName"
$TargetVersion = Join-Path $TargetRoot $ModuleVersion

Write-Host "Installing module to: $TargetVersion"

if (Test-Path $TargetVersion -and $Force) {
    Remove-Item $TargetVersion -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TargetVersion | Out-Null

# Copy module
Copy-Item "$VersionSource\*" $TargetVersion -Recurse -Force

# Validate manifest
$ManifestPath = Join-Path $TargetVersion "$ModuleName.psd1"
$Manifest = Test-ModuleManifest $ManifestPath
Write-Host "Module manifest validated: $($Manifest.Version)"

# Import module
Import-Module $TargetVersion -Force
if (-not $?) {
    Write-Error "Module import failed."
    exit 1
}

Write-Host "Module imported successfully."

# WSL loader
$WSLLoaderSource = Join-Path $RepoRoot "wsl\poshloader.sh"
$WSLLoaderTarget = "$HOME/.poshloader"

if (Test-Path $WSLLoaderSource) {
    Write-Host "[WSL] Installing poshloader..."
    $src = wslpath -a -u $WSLLoaderSource
    $dst = wslpath -a -u $WSLLoaderTarget
    wsl bash -c "cp '$src' '$dst'"
}

Write-Host "SemperFix-OMP installation complete."
