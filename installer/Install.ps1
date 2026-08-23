<#
SemperFix‑OMP Installer v1.3.1
Bruce — SemperFix Automation Suite
#>

param(
    [string]$ModuleName    = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.1",
    [switch]$Force,
    [switch]$SkipFonts
)

Write-Host "SemperFix‑OMP Installer" -ForegroundColor Cyan
Write-Host "Module: $ModuleName  Version: $ModuleVersion" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# Elevation (pwsh only — no Windows PowerShell fallback)
# ---------------------------------------------------------------------------
$IsAdmin = ([Security.Principal.WindowsPrincipal]
            [Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "Elevating installer..." -ForegroundColor Yellow
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $($args -join ' ')"
    exit
}

# ---------------------------------------------------------------------------
# Detect RepoRoot (installer folder is /installer)
# ---------------------------------------------------------------------------
$RepoRoot = Split-Path $PSscriptRoot -Parent
Write-Host "RepoRoot: $RepoRoot" -ForegroundColor Yellow

# Write RepoRoot config for module + WSL
$ConfigPath = Join-Path $env:USERPROFILE ".semperfix-omp.json"
@{ RepoRoot = $RepoRoot } | ConvertTo-Json | Set-Content $ConfigPath

# ---------------------------------------------------------------------------
# Resolve module source folder
# ---------------------------------------------------------------------------
$ModuleSourceRoot = Join-Path $RepoRoot "modules\$ModuleName"
$VersionSource    = Join-Path $ModuleSourceRoot $ModuleVersion

Write-Host "ModuleSource: $ModuleSourceRoot"
Write-Host "VersionSource: $VersionSource"

if (-not (Test-Path $VersionSource)) {
    Write-Error "Module version folder not found: $VersionSource"
    exit 1
}

# ---------------------------------------------------------------------------
# Resolve installation target
# ---------------------------------------------------------------------------
$TargetRoot = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\$ModuleName"
$TargetVersion = Join-Path $TargetRoot $ModuleVersion

Write-Host "Installing module to: $TargetVersion"

if (Test-Path $TargetVersion -and $Force) {
    Remove-Item $TargetVersion -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TargetVersion | Out-Null

# ---------------------------------------------------------------------------
# Copy module files
# ---------------------------------------------------------------------------
Copy-Item "$VersionSource\*" $TargetVersion -Recurse -Force

# ---------------------------------------------------------------------------
# Validate manifest
# ---------------------------------------------------------------------------
$ManifestPath = Join-Path $TargetVersion "$ModuleName.psd1"
$Manifest = Test-ModuleManifest $ManifestPath

Write-Host "Module manifest validated: $($Manifest.Version)"

# ---------------------------------------------------------------------------
# Import module
# ---------------------------------------------------------------------------
Import-Module $TargetVersion -Force

Write-Host "Module imported successfully." -ForegroundColor Green

# ---------------------------------------------------------------------------
# Fonts (Windows only)
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Install WSL loader
# ---------------------------------------------------------------------------
$WSLLoaderSource = Join-Path $RepoRoot "wsl\poshloader.sh"
$WSLLoaderTarget = "$HOME/.poshloader"

if (Test-Path $WSLLoaderSource) {
    Write-Host "[WSL] Installing poshloader..." -ForegroundColor Cyan
    wsl bash -c "cp `"`$(wslpath -a -u $WSLLoaderSource)`" `"`$(wslpath -a -u $WSLLoaderTarget)`""
}

Write-Host "SemperFix‑OMP installation complete." -ForegroundColor Green
