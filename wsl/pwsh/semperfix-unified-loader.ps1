# ============================================================================
# SemperFix Unified Loader
# Windows / Linux / WSL
# ============================================================================

# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------

$DiagFlagFile = Join-Path $HOME ".semperfix-diagnostics"
$DiagEnabled  = Test-Path $DiagFlagFile

function Write-SFDiag {
    param([string]$Message)

    if ($DiagEnabled) {
        Write-Host "[SemperFix] $Message" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------------------
# Platform Detection
# ---------------------------------------------------------------------------

$SF_IsWindows = $IsWindows
$SF_IsLinux   = $IsLinux

Write-SFDiag "Windows: $SF_IsWindows"
Write-SFDiag "Linux:   $SF_IsLinux"

# ---------------------------------------------------------------------------
# Ensure ~/.local/bin exists on Linux
# ---------------------------------------------------------------------------

if ($SF_IsLinux) {

    $LocalBin = "$HOME/.local/bin"

    if (Test-Path $LocalBin) {

        $PathEntries = $env:PATH -split ':'

        if ($PathEntries -notcontains $LocalBin) {
            $env:PATH = "{$LocalBin}:${env:PATH}"
        }
    }
}

# ---------------------------------------------------------------------------
# OMP Detection
# ---------------------------------------------------------------------------

$OMP = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if ($null -eq $OMP) {

    Write-Warning "[SemperFix] oh-my-posh not found in PATH."
    return
}

Write-SFDiag "OMP Path: $($OMP.Source)"

# ---------------------------------------------------------------------------
# Theme Sync File
# ---------------------------------------------------------------------------

$SyncFile = Join-Path $HOME ".poshtheme"

if (-not (Test-Path $SyncFile)) {

    Write-SFDiag "Theme sync file missing."

    "jandedobbeleer.omp.json" |
        Set-Content $SyncFile
}

# ---------------------------------------------------------------------------
# Theme Name
# ---------------------------------------------------------------------------

$Theme = (
    Get-Content $SyncFile -ErrorAction SilentlyContinue |
    Select-Object -First 1
)

if ([string]::IsNullOrWhiteSpace($Theme)) {
    $Theme = "jandedobbeleer.omp.json"
}

$Theme = $Theme.Trim()

Write-SFDiag "Theme: $Theme"

# ---------------------------------------------------------------------------
# Theme Directory
# ---------------------------------------------------------------------------

if ($SF_IsWindows) {

    $ThemeDirectory = Join-Path `
        $env:LOCALAPPDATA `
        "Programs\oh-my-posh\themes"

}
else {

    $ThemeDirectory = Join-Path `
        $HOME `
        ".poshthemes"
}

Write-SFDiag "ThemeDirectory: $ThemeDirectory"

if (-not (Test-Path $ThemeDirectory)) {

    Write-Warning "[SemperFix] Theme directory not found:"
    Write-Warning "  $ThemeDirectory"

    return
}

# ---------------------------------------------------------------------------
# Theme File
# ---------------------------------------------------------------------------

$ThemePath = Join-Path `
    $ThemeDirectory `
    $Theme

Write-SFDiag "ThemePath: $ThemePath"

if (-not (Test-Path $ThemePath)) {

    Write-Warning "[SemperFix] Theme file not found:"
    Write-Warning "  $ThemePath"

    $FallbackTheme = Join-Path `
        $ThemeDirectory `
        "jandedobbeleer.omp.json"

    if (Test-Path $FallbackTheme) {

        Write-Warning "[SemperFix] Falling back to jandedobbeleer."

        $ThemePath = $FallbackTheme
    }
    else {

        Write-Warning "[SemperFix] Fallback theme missing."

        return
    }
}

# ---------------------------------------------------------------------------
# Initialize OMP
# ---------------------------------------------------------------------------

try {

    oh-my-posh init pwsh --config $ThemePath |
        Invoke-Expression

    Write-SFDiag "OMP initialized."
}
catch {

    Write-Warning "[SemperFix] OMP initialization failed."
    return
}

# ------------------------------------------------------------------
# Load SemperFix Module
# ---------------------------------------------------------------------------

try {

    $Module = Get-Module SemperFix.OMP `
        -ListAvailable `
        -ErrorAction SilentlyContinue

    if ($null -ne $Module) {

        Import-Module SemperFix.OMP -Force

        Write-SFDiag "SemperFix.OMP loaded."
    }
    else {

        Write-SFDiag "Module not installed."
    }
}
catch {

    Write-Warning "[SemperFix] Module failed to load."
}

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------

Write-SFDiag "Loader complete."