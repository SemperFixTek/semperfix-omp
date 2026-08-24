function Resolve-RepoRoot {
    $ConfigPath = Join-Path $env:USERPROFILE ".semperfix-omp.json"
    if (Test-Path $ConfigPath) {
        return (Get-Content $ConfigPath | ConvertFrom-Json).RepoRoot
    }

    $moduleRoot = Split-Path $PSScriptRoot -Parent
    return Split-Path $moduleRoot -Parent
}
