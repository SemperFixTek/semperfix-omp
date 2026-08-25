function Set-PoshTheme {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    # Detect WSL
    $isWSL = $null -ne $env:WSL_DISTRO_NAME

    # Determine theme directory
    if ($isWSL) {
        # WSL uses symlinked ~/.poshthemes
        $themeDir = "$HOME/.poshthemes"
    }
    else {
        # Windows uses LOCALAPPDATA theme directory
        $themeDir = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Programs\oh-my-posh\themes"
    }

    # Build full theme path
    $themePath = Join-Path -Path $themeDir -ChildPath $Name

    if (-not (Test-Path -Path $themePath)) {
        Write-Error "[SemperFix] Theme not found: $themePath"
        return
    }

    # Sync file (shared between Windows + WSL)
    $syncFile = "$HOME/.poshtheme"
    Set-Content -Path $syncFile -Value $Name -Encoding UTF8

    Write-Host "[SemperFix] Theme set: $Name" -ForegroundColor Green
}
