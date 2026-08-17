function Set-PoshTheme {
<#
.SYNOPSIS
    Sets the active Oh My Posh theme and persists the selection.

.DESCRIPTION
    Applies the specified theme, updates the user's persisted theme
    preference, and initializes Oh My Posh with the new configuration.

.PARAMETER ThemeName
    The name of the theme file (e.g., paradox2.omp.json).

.EXAMPLE
    Set-PoshTheme "paradox2.omp.json"

.NOTES
    SemperFix OMP Module v1.3.0
#>

    param(
        [Parameter(Mandatory=$true)]
        [string]$ThemeName
    )

    $themePath = Resolve-ThemePath -ThemeName $ThemeName

    if (-not (Test-Path $themePath)) {
        Write-Host "❌ Theme not found: $themePath" -ForegroundColor Red
        return
    }

    [System.Environment]::SetEnvironmentVariable(
        'POSH_THEMES_VERSION',
        $ThemeName,
        'User'
    )

    $env:POSH_THEMES_VERSION = $ThemeName

    oh-my-posh init pwsh --config $themePath | Invoke-Expression

    Write-Host "✔ Theme switched to: $ThemeName" -ForegroundColor Green
}
