# SemperFix-OMP Installer v1.3.3

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipFonts
)

Write-Host "SemperFix-OMP Installer v1.3.3" -ForegroundColor Cyan

# -------------------------
# Resolve repo + module paths
# -------------------------

$repoRoot     = Split-Path -Path $PSCommandPath -Parent | Split-Path -Parent
$moduleName   = 'SemperFix.OMP'
$moduleSource = Join-Path -Path $repoRoot -ChildPath "modules\$moduleName"

$versionFolder = Get-ChildItem -Path $moduleSource -Directory |
    Sort-Object -Property Name -Descending |
    Select-Object -First 1

$moduleVersion = $versionFolder.Name
$versionSource = $versionFolder.FullName

Write-Host "Module: $moduleName  Version: $moduleVersion"
Write-Host "RepoRoot: $repoRoot"
Write-Host "ModuleSource: $moduleSource"
Write-Host "VersionSource: $versionSource"

# -------------------------
# Install module to user scope (NO VERSION SUBFOLDER)
# -------------------------

$userModuleRoot = Join-Path -Path $HOME -ChildPath "Documents\PowerShell\Modules\$moduleName"
$targetVersion  = $userModuleRoot   # Manifest modules must NOT use version subfolders

Write-Host "Installing module to: $targetVersion"

if ($Force.IsPresent -and (Test-Path -Path $targetVersion)) {
    Remove-Item -Path $targetVersion -Recurse -Force
}

New-Item -ItemType Directory -Path $targetVersion -Force | Out-Null

Get-ChildItem -Path $versionSource -Recurse -Force | ForEach-Object {
    $relative = $_.FullName.Substring($versionSource.Length).TrimStart('\','/')
    $dest     = Join-Path -Path $targetVersion -ChildPath $relative

    if ($_.PSIsContainer) {
        if (-not (Test-Path -Path $dest)) {
            New-Item -ItemType Directory -Path $dest | Out-Null
        }
    }
    else {
        Copy-Item -Path $_.FullName -Destination $dest -Force
    }
}


$manifestPath = Join-Path -Path $targetVersion -ChildPath "$moduleName.psd1"
Test-ModuleManifest -Path $manifestPath | Out-Null
Write-Host "Module manifest validated: $moduleVersion"

# -------------------------
# Inject module into profile
# -------------------------

$profilePath = $PROFILE
$importLine  = 'Import-Module SemperFix.OMP'

if (-not (Test-Path -Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content -Path $profilePath -ErrorAction SilentlyContinue

if ($profileContent -notcontains $importLine) {
    Add-Content -Path $profilePath -Value $importLine
}

Write-Host "[SemperFix] Module auto-load enabled in profile: $profilePath" -ForegroundColor Green

# -------------------------
# Import module immediately
# -------------------------

Import-Module -Name $moduleName -Force
Write-Host "[SemperFix] Module imported." -ForegroundColor Green

# -------------------------
# Deterministic font installer
# -------------------------

if (-not $SkipFonts.IsPresent) {
    $fontSource = Join-Path -Path $repoRoot -ChildPath 'fonts'
    $fontTarget = 'C:\Windows\Fonts'

    if (-not (Test-Path -Path $fontSource)) {
        Write-Warning "[Fonts] Font source folder not found: $fontSource"
    }
    else {
        $fontFiles = Get-ChildItem -Path $fontSource -Filter *.ttf -ErrorAction SilentlyContinue

        if (-not $fontFiles) {
            Write-Warning "[Fonts] No .ttf files found in $fontSource"
        }
        else {
            Write-Host "[Fonts] Installing fonts using COM registration..." -ForegroundColor Cyan

            $shell       = New-Object -ComObject Shell.Application
            $fontsFolder = $shell.NameSpace(0x14)

            foreach ($font in $fontFiles) {
                try {
                    Write-Host "[Fonts] Installing: $($font.Name)"
                    $fontsFolder.CopyHere($font.FullName, 0x10)
                    Start-Sleep -Milliseconds 250
                }
                catch {
                    Write-Warning "[Fonts] Failed to install: $($font.Name)"
                }
            }

            Write-Host "[Fonts] Font installation complete." -ForegroundColor Green
        }
    }
}

Write-Host "SemperFix-OMP installation complete." -ForegroundColor Green
