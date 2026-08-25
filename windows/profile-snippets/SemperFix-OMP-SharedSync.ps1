# SemperFix-OMP Shared Sync Helper

function Get-SemperFixThemeSyncFile {
    return "$HOME\.poshtheme"
}

function Get-SemperFixThemeName {
    $SyncFile = Get-SemperFixThemeSyncFile

    if (Test-Path $SyncFile) {
        $theme = Get-Content $SyncFile -Raw
        if (-not [string]::IsNullOrWhiteSpace($theme)) {
            return $theme.Trim()
        }
    }

    return "paradox.omp.json"
}

function Get-SemperFixThemeDirectory {
    if ($IsWindows) {
        return Join-Path $env:LOCALAPPDATA "Programs\oh-my-posh\themes"
    } else {
        return "$HOME/.poshthemes"
    }
}

function Get-SemperFixThemePath {
    $theme = Get-SemperFixThemeName
    $dir   = Get-SemperFixThemeDirectory
    return Join-Path $dir $theme
}

Export-ModuleMember -Function Get-SemperFixThemeSyncFile,Get-SemperFixThemeName,Get-SemperFixThemeDirectory,Get-SemperFixThemePath
