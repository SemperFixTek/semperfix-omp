Write-Host "Installing SemperFix OMP Module..." -ForegroundColor Cyan

# Correct module root and version folder
$moduleRoot = Join-Path $env:USERPROFILE 'Documents\PowerShell\Modules\SemperFix.OMP'
$moduleVersionPath = Join-Path $moduleRoot '1.3.0'

# Ensure module directory exists
if (-not (Test-Path $moduleVersionPath)) {
    New-Item -ItemType Directory -Path $moduleVersionPath -Force | Out-Null
}

# Copy ONLY the contents of the module folder, not the folder itself
$sourceModuleFolder = Split-Path $PSScriptRoot -Parent
Copy-Item -Path "$sourceModuleFolder\*" -Destination $moduleVersionPath -Recurse -Force

Write-Host "Module installed to $moduleVersionPath" -ForegroundColor Green

# Build profile path (PowerShell 7)
$profilePath = "$HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Ensure profile directory exists
$profileDir = Split-Path $profilePath
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Write ASCII-only profile
$profileContent = @'
# Remove OneDrive module path
$oneDriveModulePath = "$HOME\OneDrive\Documents\PowerShell\Modules"
$env:PSModulePath = ($env:PSModulePath -split ';' | Where-Object { $_ -ne $oneDriveModulePath }) -join ';'

# Ensure PowerShell 7 sees the correct module directory
$localModulePath = "$HOME\Documents\PowerShell\Modules"
if (-not ($env:PSModulePath -split ';' | Where-Object { $_ -eq $localModulePath })) {
    $env:PSModulePath = "$localModulePath;$env:PSModulePath"
}

# Load SemperFix OMP module
Import-Module SemperFix.OMP -ErrorAction Stop

# Load shared theme file if present
$sharedFile = Join-Path $env:USERPROFILE '.poshtheme'
if (Test-Path $sharedFile) {
    $env:POSH_THEMES_VERSION = Get-Content $sharedFile -ErrorAction SilentlyContinue
}

# Apply theme or default
if ($env:POSH_THEMES_VERSION) {
    Set-PoshTheme $env:POSH_THEMES_VERSION
} else {
    Set-PoshTheme 'paradox.omp.json'
}
'@

Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8

Write-Host "Profile updated at $profilePath" -ForegroundColor Green
