function Set-PoshTheme {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ThemeName
    )

    $themePath = Resolve-ThemePath -ThemeName $ThemeName

    if (-not (Test-Path $themePath)) {
        Write-Host "Theme not found: $themePath" -ForegroundColor Red
        return
    }

    [System.Environment]::SetEnvironmentVariable(
        'POSH_THEMES_VERSION',
        $ThemeName,
        'User'
    )
    $env:POSH_THEMES_VERSION = $ThemeName

    $sharedFile = Join-Path $env:USERPROFILE '.poshtheme'
    Set-Content -Path $sharedFile -Value $ThemeName -Encoding UTF8

    oh-my-posh init pwsh --config $themePath | Invoke-Expression

    Write-Host "Theme switched to: $ThemeName" -ForegroundColor Green
}
