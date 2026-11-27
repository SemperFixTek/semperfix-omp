# PWSH $PROFILE linked profile.ps1 file for MS Powershell 7.x for linux
#For OMP installation under Powershell 7.x in Linux, this file lives
# here: /home/sfx/.config/powershell/Microsoft.PowerShell_profile.ps1

# ====================================================================
# SemperFix OMP Linux / WSL PowerShell Profile
# Version: 1.3.3
# ====================================================================

# --------------------------------------------------------------------
# Helper: Logging
# --------------------------------------------------------------------

function Write-SemperFixWarning {
    param([string]$Message)

    Write-Warning "[SemperFix] $Message"
}

# --------------------------------------------------------------------
# 1. Ensure ~/.local/bin is available
# --------------------------------------------------------------------

$localBin = Join-Path $HOME ".local/bin"

if (Test-Path $localBin) {

    $pathEntries = $env:PATH -split ':'

    if ($pathEntries -notcontains $localBin) {
        $env:PATH = "${localBin}:${env:PATH}"
    }
}

# --------------------------------------------------------------------
# 2. Verify oh-my-posh
# --------------------------------------------------------------------

$omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if ($null -eq $omp) {
    Write-SemperFixWarning "oh-my-posh not found in PATH."
    return
}

# --------------------------------------------------------------------
# 3. Shared sync file
# --------------------------------------------------------------------

$syncFile = Join-Path $HOME ".poshtheme"

if (-not (Test-Path $syncFile)) {

    Write-SemperFixWarning "Theme sync file missing. Creating default."

    "jandedobbeleer.omp.json" |
        Set-Content -Path $syncFile
}

# --------------------------------------------------------------------
# 4. Read theme
# --------------------------------------------------------------------

$theme = (
    Get-Content $syncFile -ErrorAction SilentlyContinue |
    Select-Object -First 1
)

if ([string]::IsNullOrWhiteSpace($theme)) {

    Write-SemperFixWarning "Theme sync file is empty."

    $theme = "jandedobbeleer.omp.json"
}

$theme = $theme.Trim()

# --------------------------------------------------------------------
# 5. Resolve theme directory
# --------------------------------------------------------------------

$themeDirectory = Join-Path $HOME ".poshthemes"

if (-not (Test-Path $themeDirectory)) {

    Write-SemperFixWarning "Theme directory not found: $themeDirectory"

    return
}

# --------------------------------------------------------------------
# 6. Resolve theme file
# --------------------------------------------------------------------

$themePath = Join-Path $themeDirectory $theme

if (-not (Test-Path $themePath)) {

    Write-SemperFixWarning "Theme file not found: $themePath"

    # Fallback theme attempt
    $fallbackTheme = Join-Path $themeDirectory "jandedobbeleer.omp.json"

    if (Test-Path $fallbackTheme) {

        Write-SemperFixWarning "Falling back to jandedobbeleer."

        $themePath = $fallbackTheme
    }
    else {

        Write-SemperFixWarning "No fallback theme available."
        return
    }
}

# --------------------------------------------------------------------
# 7. Initialize OMP
# --------------------------------------------------------------------

try {

    oh-my-posh init pwsh --config $themePath |
        Invoke-Expression
}
catch {

    Write-SemperFixWarning "oh-my-posh initialization failed."
    return
}

# --------------------------------------------------------------------
# 8. Load SemperFix.OMP if installed
# --------------------------------------------------------------------

$module = Get-Module SemperFix.OMP -ListAvailable `
    -ErrorAction SilentlyContinue

if ($null -ne $module) {

    try {

        Import-Module SemperFix.OMP -Force -ErrorAction Stop
    }
    catch {

        Write-SemperFixWarning "SemperFix.OMP failed to load."
    }
}
else {

    Write-Verbose "[SemperFix] Module not installed."
}

# --------------------------------------------------------------------
# 9. Optional startup diagnostic
# --------------------------------------------------------------------

$diagFlag = Join-Path $HOME ".semperfix-diagnostics"

if (Test-Path $diagFlag) {

    Write-Host ""
    Write-Host "=== SemperFix Startup Diagnostics ===" `
        -ForegroundColor Cyan

    Write-Host "Theme File:      $syncFile"
    Write-Host "Theme Name:      $theme"
    Write-Host "Theme Path:      $themePath"
    Write-Host "OMP Path:        $($omp.Source)"
    Write-Host "Module Present:  $($null -ne $module)"
    Write-Host ""

}