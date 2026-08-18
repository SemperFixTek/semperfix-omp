# SemperFix OMP Shared Theme Sync

$sharedFile = Join-Path $env:USERPROFILE '.poshtheme'

if (Test-Path $sharedFile) {
    $theme = Get-Content $sharedFile -ErrorAction SilentlyContinue
    if ($theme) {
        $env:POSH_THEMES_VERSION = $theme
    }
}
