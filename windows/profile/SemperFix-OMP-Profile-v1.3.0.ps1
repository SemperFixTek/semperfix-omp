# SemperFix OMP Profile Block v1.3.0
# Persistent theme storage + universal loader + theme registry

# Ensure theme path is always available
$env:POSH_THEMES_PATH = 'C:\Users\User\AppData\Local\Programs\oh-my-posh\themes'

function Set-PoshTheme {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ThemeName
    )

    $themePath = Join-Path $env:POSH_THEMES_PATH $ThemeName

    if (-not (Test-Path $themePath)) {
        Write-Host "❌ Theme not found: $themePath" -ForegroundColor Red
        return
    }

    # Persist theme across terminal sessions
    [System.Environment]::SetEnvironmentVariable(
        'POSH_THEMES_VERSION',
        $ThemeName,
        'User'
    )

    # Update current session
    $env:POSH_THEMES_VERSION = $ThemeName

    # Initialize OMP with new theme
    oh-my-posh init pwsh --config $themePath | Invoke-Expression

    Write-Host "✔ Theme switched to: $ThemeName" -ForegroundColor Green
}

function List-PoshThemes {
    Write-Host "📂 Available Oh My Posh Themes:" -ForegroundColor Cyan

    Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json |
        Sort-Object Name |
        ForEach-Object {
            if ($_.Name -eq $env:POSH_THEMES_VERSION) {
                Write-Host " → $_ (active)" -ForegroundColor Green
            } else {
                Write-Host "   $_"
            }
        }
}

function Choose-PoshTheme {
    $themes = Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json |
              Sort-Object Name

    if (-not $themes) {
        Write-Host "❌ No themes found in $env:POSH_THEMES_PATH" -ForegroundColor Red
        return
    }

    $selection = $themes |
        Out-GridView -Title "Select an Oh My Posh Theme" -PassThru

    if ($selection) {
        Set-PoshTheme $selection.Name
    }
}

# Load persisted theme (or default if none exists)
if (-not $env:POSH_THEMES_VERSION) {
    $env:POSH_THEMES_VERSION = 'paradox2.omp.json'
}

# Initialize OMP using persisted theme
Set-PoshTheme $env:POSH_THEMES_VERSION
