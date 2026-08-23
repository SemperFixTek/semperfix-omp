param(
    [string]$ModuleName = "SemperFix.OMP",
    [string]$ModuleVersion = "1.3.0",
    [switch]$Force,
    [switch]$SkipFonts
)

# Allow environment variable SEMPERFIX_SKIP_FONTS=1 to also skip fonts
if (-not $SkipFonts -and $env:SEMPERFIX_SKIP_FONTS) {
    $SkipFonts = $true
}

# --------------------------------------------------------------------
# Robust Repo Root Detection (fixes empty $PSScriptRoot issue)
# --------------------------------------------------------------------
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    $RepoRoot = Split-Path $scriptPath -Parent
} else {
    Write-Warning "Installer was not executed as a file. Falling back to current directory."
    $RepoRoot = Get-Location
}

Write-Host "RepoRoot: $RepoRoot" -ForegroundColor DarkGray

# --------------------------------------------------------------------
# Elevation Check
# --------------------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Elevating installer..." -ForegroundColor Yellow
    Start-Process pwsh "-ExecutionPolicy Bypass -File `"$scriptPath`" $args" -Verb RunAs
    exit
}

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan
Write-Host "Module: $ModuleName  Version: $ModuleVersion" -ForegroundColor Cyan

# --------------------------------------------------------------------
# Module Source Detection
# --------------------------------------------------------------------
$moduleSource = Join-Path $RepoRoot "modules\$ModuleName"
$versionSource = Join-Path $moduleSource $ModuleVersion

Write-Host "ModuleSource: $moduleSource" -ForegroundColor DarkGray
Write-Host "VersionSource: $versionSource" -ForegroundColor DarkGray

if (-not (Test-Path $versionSource)) {
    Write-Error "Module version folder not found: $versionSource"
    exit 1
}

# --------------------------------------------------------------------
# Install Module
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
# Import Module (robust: import by name + version)
# --------------------------------------------------------------------
try {
    Import-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Force -ErrorAction Stop
    Write-Host "Module imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module: $_"
    exit 1
}

# --------------------------------------------------------------------
# Font Installation (SkipFonts supported)
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
        } catch {
            Write-Warning "Could not refresh DirectWrite cache."
        }
    }
}

# --------------------------------------------------------------------
# Install WSL Loader
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
