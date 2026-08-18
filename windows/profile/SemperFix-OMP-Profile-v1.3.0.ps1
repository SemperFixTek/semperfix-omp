# SemperFix OMP Windows Profile v1.3.0

Import-Module SemperFix.OMP -ErrorAction SilentlyContinue

if ($env:POSH_THEMES_VERSION) {
    Set-PoshTheme $env:POSH_THEMES_VERSION
} else {
    Set-PoshTheme 'paradox.omp.json'
}
