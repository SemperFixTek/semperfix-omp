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

# Elevation check (relaunches elevated if not already)
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Elevating installer..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    exit
}

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan
Write-Host "Module: $ModuleName  Version: $ModuleVersion" -ForegroundColor Cyan

# Detect repo root (installer folder is inside /installer)
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Module source is in /modules/SemperFix.OMP/<version>
$moduleSource = Join-Path $RepoRoot "modules\$ModuleName"
$versionSource = Join-Path $moduleSource $ModuleVersion

if (-not (Test-Path $versionSource)) {
    Write-Error "Module version folder not found: $versionSource"
    exit 1
}

# Install module to user's PowerShell Modules folder
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

# Validate and import module
try {
    $manifest = Join-Path $installTarget "$ModuleName.psd1"
    if (Test-Path $manifest) {
        Write-Host "Module manifest validated:  $ModuleVersion" -ForegroundColor Green
    } else {
        Write-Warning "Module manifest not found at $manifest"
    }

    Import-Module $installTarget -Force -ErrorAction Stop
    Write-Host "Module imported successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to import module: $_"
    exit 1
}

# Fonts installation stage (guarded by SkipFonts)
if ($SkipFonts) {
    Write-Host "[Fonts] Skipping font installation (SkipFonts flag set)." -ForegroundColor Yellow
} else {
    Write-Host "[Fonts] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

    $fontSource = Join-Path $RepoRoot "windows\fonts"
    $fontTarget = "$env:WINDIR\Fonts"

    if (-not (Test-Path $fontSource)) {
        Write-Warning "Font source folder not found: $fontSource. Skipping fonts."
    } else {
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

            try {
                Copy-Item $fontFile $fontTarget -Force -ErrorAction Stop
                $FontsFolder.CopyHere($fontFile, 0x10)
            } catch {
                Write-Warning "Could not copy/register font $($_.Name): $_"
            }
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
    }
}

# WSL loader install (existing behavior)
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
