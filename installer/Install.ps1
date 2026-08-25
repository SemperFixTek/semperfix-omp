# SemperFix-OMP Installer

param(
    [switch]$Force,
    [switch]$SkipFonts
)

Write-Host "SemperFix-OMP Installer" -ForegroundColor Cyan

$RepoRoot    = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$ModuleName  = "SemperFix.OMP"
$ModuleSource = Join-Path $RepoRoot "modules\$ModuleName"

$VersionFolder = Get-ChildItem $ModuleSource -Directory | Sort-Object Name -Descending | Select-Object -First 1
$ModuleVersion = $VersionFolder.Name
$VersionSource = $VersionFolder.FullName

Write-Host "Module: $ModuleName  Version: $ModuleVersion"
Write-Host "RepoRoot: $RepoRoot"
Write-Host "ModuleSource: $ModuleSource"
Write-Host "VersionSource: $VersionSource"

$UserModuleRoot = Join-Path $HOME "Documents\PowerShell\Modules\$ModuleName"
$TargetVersion  = Join-Path $UserModuleRoot $ModuleVersion

Write-Host "Installing module to: $TargetVersion"

if ($Force -and (Test-Path $TargetVersion)) {
    Remove-Item $TargetVersion -Recurse -Force
}

New-Item -ItemType Directory -Path $TargetVersion -Force | Out-Null

# Safe copy
Get-ChildItem -Path $VersionSource -Recurse -Force | ForEach-Object {
    $relative = $_.FullName.Substring($VersionSource.Length).TrimStart('\','/')
    $dest     = Join-Path $TargetVersion $relative

    if ($_.PSIsContainer) {
        if (-not (Test-Path $dest)) {
            New-Item -ItemType Directory -Path $dest | Out-Null
        }
    } else {
        Copy-Item $_.FullName $dest -Force
    }
}

$ManifestPath = Join-Path $TargetVersion "$ModuleName.psd1"
Test-ModuleManifest $ManifestPath | Out-Null
Write-Host "Module manifest validated: $ModuleVersion"

Write-Host "[SemperFix] Module installed. Import manually if needed:" -ForegroundColor Yellow
Write-Host "  Import-Module $ModuleName -Force"

# ================================
# SemperFix-OMP Deterministic Font Installer
# ================================

if (-not $SkipFonts) {

    $FontSource = Join-Path $RepoRoot "fonts"
    $FontTarget = "C:\Windows\Fonts"

    if (-not (Test-Path $FontSource)) {
        Write-Warning "[Fonts] Font source folder not found: $FontSource"
        return
    }

    $FontFiles = Get-ChildItem $FontSource -Filter *.ttf -ErrorAction SilentlyContinue

    if (-not $FontFiles) {
        Write-Warning "[Fonts] No .ttf files found in $FontSource"
        return
    }

    Write-Host "[Fonts] Installing fonts using COM registration..." -ForegroundColor Cyan

    # COM-based font installation (required for Windows 10/11)
    $Shell = New-Object -ComObject Shell.Application
    $FontsFolder = $Shell.NameSpace(0x14)   # Windows Fonts special folder

    foreach ($font in $FontFiles) {
        try {
            Write-Host "[Fonts] Installing: $($font.Name)"
            $FontsFolder.CopyHere($font.FullName, 0x10)  # 0x10 = No UI
            Start-Sleep -Milliseconds 250
        }
        catch {
            Write-Warning "[Fonts] Failed to install: $($font.Name)"
        }
    }

    Write-Host "[Fonts] Font installation complete." -ForegroundColor Green
}


Write-Host "SemperFix-OMP installation complete." -ForegroundColor Green
