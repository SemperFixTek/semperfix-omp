function Resolve-ThemePath {
    param([string]$ThemeName)

    if (-not $env:POSH_THEMES_PATH) {
        $env:POSH_THEMES_PATH = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes'
    }

    Join-Path $env:POSH_THEMES_PATH $ThemeName
}
