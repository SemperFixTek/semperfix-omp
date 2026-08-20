<#
    SemperFix-OMP Windows Installer v1.0.0
    - Installs SemperFix.OMP module
    - Wires PowerShell profile
    - Prepares shared theme file
    - Validates WSL + oh-my-posh
#>

param(
    [switch]$Force
)

Write-Host "SemperFix-OMP Windows Installer v1.0.0" -ForegroundColor Cyan

# 1. Resolve key paths
$UserProfile      = $env:USERPROFILE
$Documents        = Join-Path $UserProfile 'Documents'
$PsModulesPath    = Join-Path $Documents 'PowerShell\Modules'
$ProfilePath      = $PROFILE
$SharedThemeFile  = Join-Path $UserProfile '.poshtheme'

# 2. Ensure module directory exists
if (-not (Test-Path $PsModulesPath)) {
    Write-Host "Creating PowerShell module directory at $PsModulesPath"
    New-Item -ItemType Directory -Path $PsModulesPath -Force | Out-Null
}

# 3. Install SemperFix.OMP module (correct repo layout)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path $ScriptRoot -Parent

$SourceModulePath = Join-Path $RepoRoot 'module\SemperFix.OMP'
$TargetModulePath = Join-Path $PsModulesPath 'SemperFix.OMP'

if (-not (Test-Path $SourceModulePath)) {
    Write-Host "ERROR: SemperFix.OMP module source not found at $SourceModulePath" -ForegroundColor Red
    return
}

Write-Host "Installing SemperFix.OMP from $SourceModulePath"

if ((Test-Path $TargetModulePath) -and (-not $Force)) {
    Write-Host "SemperFix.OMP already installed at $TargetModulePath (use -Force to overwrite)" -ForegroundColor Yellow
} else {
    if (Test-Path $TargetModulePath) { Remove-Item $TargetModulePath -Recurse -Force }
    Copy-Item $SourceModulePath -Destination $TargetModulePath -Recurse -Force
}

# 4. Ensure shared theme file exists with a sane default
if (-not (Test-Path $SharedThemeFile) -or $Force) {
    Write-Host "Creating shared theme file at $SharedThemeFile with default theme 'paradox.omp.json'"
    "paradox.omp.json`r`n" | Set-Content -Path $SharedThemeFile -Encoding ASCII
} else {
    Write-Host "Shared theme file already exists at $SharedThemeFile"
}

# 5. Write PowerShell profile (SAFE single-quoted here-string)
Write-Host "Updating PowerShell profile at $ProfilePath"

$ProfileContent = @'
# SemperFix-OMP Profile Bootstrap v1.0.0

# Remove OneDrive module path (fast version)
$oneDriveModulePath = "$HOME\OneDrive\Documents\PowerShell\Modules"
$env:PSModulePath = $env:PSModulePath.Replace("$oneDriveModulePath;", "")

# Ensure PowerShell 7 sees the correct module directory
$localModulePath = "$HOME\Documents\PowerShell\Modules"
if (-not (($env:PSModulePath -split ';') -contains $localModulePath)) {
    $env:PSModulePath = "$localModulePath;$env:PSModulePath"
}

# Temporary fast prompt
function Set-TemporaryPrompt {
    $global:OMP_INITIALIZED = $false
    function prompt { "PS> " }
}
Set-TemporaryPrompt

# Shared theme file
$sharedFile = Join-Path $env:USERPROFILE '.poshtheme'

# Safe read
if (Test-Path $sharedFile) {
    $raw = Get-Content $sharedFile -ErrorAction SilentlyContinue | Select-Object -First 1
    $theme = $raw.Trim()
    if ([string]::IsNullOrWhiteSpace($theme)) {
        $theme = "paradox.omp.json"
    }
} else {
    $theme = "paradox.omp.json"
}

# Cache theme path
$script:ThemePath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\$theme"

# Async OMP load using first-prompt callback
Add-Type -TypeDefinition @"
using System;
public class OMPInit {
    public static bool Initialized = false;
}
"@

function prompt {
    if (-not [OMPInit]::Initialized) {
        [OMPInit]::Initialized = $true
        oh-my-posh init pwsh --config $script:ThemePath | Invoke-Expression
    }
    & $function:prompt
}

# Import SemperFix.OMP (lazy but in current runspace)
Import-Module SemperFix.OMP -ErrorAction SilentlyContinue
'@

Set-Content -Path $ProfilePath -Value $ProfileContent -Encoding UTF8

# 6. Basic validation
Write-Host "Validating oh-my-posh presence..." -NoNewline
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "oh-my-posh not found. Install from https://ohmyposh.dev and re-run installer." -ForegroundColor Yellow
} else {
    Write-Host " OK" -ForegroundColor Green
}

Write-Host "Validating WSL presence..." -NoNewline
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "WSL not found or not enabled. Cross-system sync unavailable until WSL is installed." -ForegroundColor Yellow
} else {
    Write-Host " OK" -ForegroundColor Green
}

Write-Host ""
Write-Host "SemperFix-OMP Windows installation complete." -ForegroundColor Cyan
Write-Host "Open a new PowerShell 7 session to see the prompt, then run 'wsl' to verify cross-system theme sync."
