function Set-PoshTheme {
<#
.SYNOPSIS
    Sets the active Oh My Posh theme and persists the selection.

.DESCRIPTION
    Applies the specified theme, updates the shared theme file for WSL,
    and initializes Oh My Posh with the new configuration.

.PARAMETER ThemeName
    The name of the theme file (e.g., jandedobbeleer.omp.json).
#>

    param(
        [Parameter(Mandatory = $true)]
        [string]$ThemeName
    )

    $themePath = Resolve-ThemePath -ThemeName $ThemeName

    if (-not (Test-Path $themePath)) {
        Write-Host "❌ Theme not found: $themePath" -ForegroundColor Red
        return
    }

    # Persist for Windows
    [System.Environment]::SetEnvironmentVariable(
        'POSH_THEMES_VERSION',
        $ThemeName,
        'User'
    )
    $env:POSH_THEMES_VERSION = $ThemeName

    # Persist for WSL via shared file
    $sharedFile = Join-Path $env:USERPROFILE '.poshtheme'
    Set-Content -Path $sharedFile -Value $ThemeName -Encoding UTF8

    # Apply theme in PowerShell
    oh-my-posh init pwsh --config $themePath | Invoke-Expression

    Write-Host "✔ Theme switched to: $ThemeName" -ForegroundColor Green
}
