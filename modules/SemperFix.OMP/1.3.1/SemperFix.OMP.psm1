# SemperFix.OMP.psm1 v1.3.2 loader

function Resolve-PoshThemeDirectory {
    if ($IsWindows) {
        return Join-Path $env:LOCALAPPDATA "Programs\oh-my-posh\themes"
    } else {
        return "$HOME/.poshthemes"
    }
}

function Resolve-PoshThemeSyncFile {
    return "$HOME\.poshtheme"
}

function Get-PoshThemes {
    $ThemeDir = Resolve-PoshThemeDirectory

    if (-not (Test-Path $ThemeDir)) {
        Write-Warning "[SemperFix] Theme directory not found: $ThemeDir"
        return
    }

    Get-ChildItem $ThemeDir -Filter *.omp.json
}

function Get-PoshTheme {
    $SyncFile = Resolve-PoshThemeSyncFile
    if (Test-Path $SyncFile) {
        Get-Content $SyncFile -Raw
    } else {
        Write-Warning "[SemperFix] No current theme set."
    }
}

function Select-PoshTheme {
    param(
        [Parameter(Position = 0)]
        [string]$Name
    )

    $ThemeDir = Resolve-PoshThemeDirectory
    $SyncFile = Resolve-PoshThemeSyncFile

    if (-not (Test-Path $ThemeDir)) {
        Write-Warning "[SemperFix] Theme directory not found: $ThemeDir"
        return
    }

    if (-not $Name) {
        Write-Host "Available themes:" -ForegroundColor Cyan
        Get-ChildItem $ThemeDir -Filter *.omp.json | Select-Object -ExpandProperty Name
        return
    }

    $ThemePath = Join-Path $ThemeDir $Name

    if (-not (Test-Path $ThemePath)) {
        Write-Warning "[SemperFix] Theme not found: $ThemePath"
        return
    }

    Set-Content -Path $SyncFile -Value $Name -Encoding UTF8

    oh-my-posh init pwsh --config $ThemePath | Invoke-Expression

    Write-Host "[SemperFix] Theme applied: $Name" -ForegroundColor Green
}

Set-Alias gpt Get-PoshTheme
Set-Alias spt Select-PoshTheme
Set-Alias ppt Get-PoshThemes

Export-ModuleMember -Function Get-PoshTheme,Get-PoshThemes,Select-PoshTheme -Alias gpt,spt,ppt
