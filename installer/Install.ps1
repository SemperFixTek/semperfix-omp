param(
    [string]$ModuleName = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.1",
    [switch]$Force,
    [switch]$SkipFonts
)

# --------------------------------------------------------------------
# Repo root detection (stable via PSCommandPath)
# --------------------------------------------------------------------
$scriptPath    = $PSCommandPath
$InstallerRoot = Split-Path $scriptPath -Parent
$RepoRoot      = Split-Path $InstallerRoot -Parent

Write-Host "RepoRoot: $RepoRoot" -ForegroundColor DarkGray

# --------------------------------------------------------------------
# SkipFonts via environment variable
# --------------------------------------------------------------------
if (-not $SkipFonts -and $env:SEMPERFIX_SKIP_FONTS) {
    $SkipFonts = $true
}

# --------------------------------------------------------------------
# Elevation (under pwsh 7)
# --------------------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Elevating installer under PowerShell 7..." -ForegroundColor Yellow
    Start-Process pwsh "-ExecutionPolicy Bypass -File `"$scriptPath`" $args" -Verb RunAs
    exit
}

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan
Write-Host "Module: $ModuleName  Version: $ModuleVersion" -ForegroundColor Cyan

# --------------------------------------------------------------------
# Module source detection
# --------------------------------------------------------------------
$moduleSource  = Join-Path $RepoRoot "modules\$ModuleName"
$versionSource = Join-Path $moduleSource $ModuleVersion

Write-Host "ModuleSource: $moduleSource"   -ForegroundColor DarkGray
Write-Host "VersionSource: $versionSource" -ForegroundColor DarkGray

if (-not (Test-Path $versionSource)) {
    Write-Error "Module version folder not found: $versionSource"
    exit 1
}

# --------------------------------------------------------------------
# Install module
# --------------------------------------------------------------------
$installTarget = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\$ModuleName\$ModuleVersion"
Write-Host "Installing module to: $installTarget" -ForegroundColor Cyan

if (Test-Path $installTarget) {
    if ($Force) {
        Remove-Item $installTarget -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Module already exists. Use -Force to overwrite." -ForegroundColor Yellow
    }
}

Copy-Item -Path $versionSource -Destination $installTarget -Recurse -Force

# --------------------------------------------------------------------
# Import module (by name + version)
# --------------------------------------------------------------------
try {
    Import-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Force -ErrorAction Stop
    Write-Host "Module imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module: $_"
    exit 1
}

# --------------------------------------------------------------------
# Fonts (optional via SkipFonts)
# --------------------------------------------------------------------
if ($SkipFonts) {
    Write-Host "[Fonts] Skipping font installation (SkipFonts flag set)." -ForegroundColor Yellow
} else {
    Write-Host "[Fonts] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

    $fontSource = Join-Path $RepoRoot "windows\fonts"
    $fontTarget = "$env:WINDIR\Fonts"

    if (-not (Test-Path $fontSource)) {
        Write-Warning "Font source folder not found: $fontSource. Skipping fonts."
    } else {
        Write-Host "[Fonts] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
        Get-ChildItem $fontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } | ForEach-Object {
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        }

        $Shell       = New-Object -ComObject Shell.Application
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
        } catch {
            Write-Warning "Could not refresh DirectWrite cache."
        }
    }
}

# --------------------------------------------------------------------
# WSL loader install
# --------------------------------------------------------------------
try {
    $poshloaderSource = Join-Path $RepoRoot "wsl\poshloader.sh"
    $poshloaderTarget = Join-Path $env:USERPROFILE ".poshloader"

    if (Test-Path $poshloaderSource) {
        Copy-Item -Path $poshloaderSource -Destination $poshloaderTarget -Force
        Write-Host "WSL loader installed to: $poshloaderTarget" -ForegroundColor Green
    } else {
        Write-Warning "WSL loader source not found: $poshloaderSource"
    }
} catch {
    Write-Warning "Failed to install WSL loader: $_"
}

Write-Host "SemperFix-OMP installation complete." -ForegroundColor Cyan
