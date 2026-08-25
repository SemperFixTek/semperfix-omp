function Get-PoshTheme {
    param()

    $themeFile = "$HOME/.poshtheme"

    if (-not (Test-Path $themeFile)) {
        Write-Warning "[SemperFix] No theme selected."
        return $null
    }

    $themeName = Get-Content -Path $themeFile -ErrorAction SilentlyContinue

    if ([string]::IsNullOrWhiteSpace($themeName)) {
        Write-Warning "[SemperFix] Theme file is empty."
        return $null
    }

    # Detect WSL
    $isWSL = $null -ne $env:WSL_DISTRO_NAME

    # Determine theme directory
    if ($isWSL) {
        $themeDir = "$HOME/.poshthemes"
    }
    else {
        $themeDir = Join-Path $env:LOCALAPPDATA "Programs\oh-my-posh\themes"
    }

    $themePath = Join-Path $themeDir $themeName

    if (-not (Test-Path $themePath)) {
        Write-Warning "[SemperFix] Theme '$themeName' not found in: $themeDir"
        return $null
    }

    # Return structured object for GUI + console pickers
    [PSCustomObject]@{
        Name     = $themeName
        FullName = $themePath
    }
}
