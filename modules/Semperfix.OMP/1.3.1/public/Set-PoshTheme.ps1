function Set-PoshTheme {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $themePath = "$HOME/.poshthemes/$Name"
    if (-not (Test-Path $themePath)) {
        Write-Error "[SemperFix] Theme not found: $themePath"
        return
    }

    Set-Content "$HOME/.poshtheme" $Name
    Write-Host "[SemperFix] Theme set: $Name" -ForegroundColor Green
}
