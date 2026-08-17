function Resolve-ThemePath {
    param([string]$ThemeName)
    Join-Path $env:POSH_THEMES_PATH $ThemeName
}
