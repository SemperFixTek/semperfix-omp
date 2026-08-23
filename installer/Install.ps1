param(
    [string]$ModuleName    = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.1",
    [switch]$Force,
    [switch]$SkipFonts
)

#Requires -Version 7.0

# Force PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Restarting installer under PowerShell 7..." -ForegroundColor Yellow
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($args -join ' ')"
    exit
}

Write-Host "SemperFix-OMP Installer"
Write-Host "Module: $ModuleName  Version: $ModuleVersion"

# RepoRoot
$RepoRoot = Split-Path $PSscriptRoot -Parent
Write-Host "RepoRoot: $RepoRoot"

@{ RepoRoot = $RepoRoot } |
    ConvertTo-Json |
    Set-Content "$env:USERPROFILE\.semperfix-omp.json"

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

if ((Test-Path $TargetVersion) -and $Force) {
    Remove-Item $TargetVersion -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TargetVersion | Out-Null

# SAFE COPY (bulletproof)
Get-ChildItem -Path $VersionSource -Recurse -Force |
    ForEach-Object {
        $dest = $_.FullName.Replace($VersionSource, $TargetVersion)
        if ($_.PSIsContainer) {
            if (-not (Test-Path $dest)) {
                New-Item -ItemType Directory -Path $dest | Out-Null
            }
        } else {
            Copy-Item $_.FullName $dest -Force
        }
    }

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

# Fonts (optional)
if (-not $SkipFonts) {
    Write-Host "[Fonts] Installing JetBrainsMono Nerd Font..." -ForegroundColor Cyan

    $FontSource = Join-Path $RepoRoot "windows\fonts"
    $FontTarget = "$env:WINDIR\Fonts"

    if (-not (Test-Path $FontSource)) {
        Write-Warning "[Fonts] Font source not found: $FontSource"
    }
    else {
        Write-Host "[Fonts] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
        Get-ChildItem $FontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } |
            Remove-Item -Force -ErrorAction SilentlyContinue

        Write-Host "[Fonts] Installing new fonts..." -ForegroundColor Yellow

        $Shell       = New-Object -ComObject Shell.Application
        $FontsFolder = $Shell.NameSpace($FontTarget)

        Get-ChildItem $FontSource -Filter *.ttf | ForEach-Object {
            Write-Host "Installing font: $($_.Name)"
            Copy-Item $_.FullName $FontTarget -Force -ErrorAction SilentlyContinue
            $FontsFolder.CopyHere($_.FullName, 0x10)
        }

        Write-Host "[Fonts] Refreshing DirectWrite cache..."
        rundll32.exe "C:\Windows\System32\fntcache.dll",FontCache
    }
}

# WSL loader
$WSLLoaderSource = Join-Path $RepoRoot "wsl\poshloader.sh"
$WSLLoaderTarget = "$HOME/.poshloader"

if (Test-Path $WSLLoaderSource) {
    Write-Host "[WSL] Installing poshloader..."
    $src = wslpath -a -u $WSLLoaderSource
    $dst = wslpath -a -u $WSLLoaderTarget
    wsl bash -c "cp '$src' '$dst'"
}

Write-Host "SemperFix-OMP installation complete." -ForegroundColor Green
