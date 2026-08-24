#requires -Version 7.0
param(
    [switch]$Force,
    [switch]$SkipFonts
)

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan

# --- Resolve repo root ---
$RepoRoot = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$ModuleName = "SemperFix.OMP"
$ModuleSource = Join-Path $RepoRoot "modules\$ModuleName"

# --- Detect version folder ---
$VersionFolder = Get-ChildItem $ModuleSource -Directory | Sort-Object Name -Descending | Select-Object -First 1
$ModuleVersion = $VersionFolder.Name
$VersionSource = $VersionFolder.FullName

Write-Host "Module: $ModuleName  Version: $ModuleVersion"
Write-Host "RepoRoot: $RepoRoot"
Write-Host "ModuleSource: $ModuleSource"
Write-Host "VersionSource: $VersionSource"

# --- Install target ---
$UserModuleRoot = Join-Path $HOME "Documents\PowerShell\Modules\$ModuleName"
$TargetVersion = Join-Path $UserModuleRoot $ModuleVersion

Write-Host "Installing module to: $TargetVersion"

# --- Create target folder ---
if (-not (Test-Path $TargetVersion)) {
    New-Item -ItemType Directory -Path $TargetVersion | Out-Null
}

# --- Copy files (only if source != target) ---
if ($VersionSource -ne $TargetVersion) {
    Write-Host "Copying module files..."
    Get-ChildItem $VersionSource -Recurse | ForEach-Object {
        $dest = $_.FullName.Replace($VersionSource, $TargetVersion)
        if (-not (Test-Path $dest)) {
            Copy-Item $_.FullName $dest -Force
        }
    }
} else {
    Write-Host "Source and target are identical — skipping copy."
}

# --- Validate manifest ---
$Manifest = Join-Path $TargetVersion "$ModuleName.psd1"
Test-ModuleManifest $Manifest | Out-Null
Write-Host "Module manifest validated: $ModuleVersion"

# --- Import module ---
try {
    Import-Module $TargetVersion -Force -ErrorAction Stop
    Write-Host "Module imported successfully." -ForegroundColor Green
}
catch {
    Write-Error "Module import failed: $_"
    return
}

# --- Install fonts ---
if (-not $SkipFonts) {
    Write-Host "[Fonts] Installing JetBrainsMono Nerd Font..."
    $FontSource = Join-Path $RepoRoot "fonts"
    $FontTarget = "C:\Windows\Fonts"

    Get-ChildItem $FontSource -Filter *.ttf | ForEach-Object {
        $dest = Join-Path $FontTarget $_.Name
        if (-not (Test-Path $dest)) {
            Copy-Item $_.FullName $dest -Force
            Write-Host "Installed font: $($_.Name)"
        }
    }
}

# --- Install WSL poshloader ---
$WSLTarget = Join-Path $RepoRoot "wsl"
if (Test-Path $WSLTarget) {
    Write-Host "[WSL] Installing poshloader..."
    $WSLHome = "\\wsl$\Ubuntu\home\$env:USERNAME"
    $WSLPosh = Join-Path $WSLHome ".poshloader"

    if (-not (Test-Path $WSLPosh)) {
        New-Item -ItemType Directory -Path $WSLPosh | Out-Null
    }

    Copy-Item "$WSLTarget\poshloader.sh" $WSLPosh -Force
}

Write-Host "SemperFix-OMP installation complete." -ForegroundColor Cyan
