function Repair-PoshFont {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Repairing JetBrainsMono Nerd Font..." -ForegroundColor Cyan

    # Load repo root from installer config
    $ConfigPath = Join-Path $env:USERPROFILE ".semperfix-omp.json"
    $RepoRoot   = $null

    if (Test-Path $ConfigPath) {
        try {
            $cfg = Get-Content $ConfigPath | ConvertFrom-Json
            $RepoRoot = $cfg.RepoRoot
        } catch {
            Write-Warning "[SemperFix] Could not read RepoRoot from config. Falling back to module-relative path."
        }
    }

    # Fallback: derive repo root from module path (less reliable)
    if (-not $RepoRoot) {
        $moduleRoot = Split-Path $PSScriptRoot -Parent
        $RepoRoot   = Split-Path $moduleRoot -Parent
    }

    # Repo-aware font source
    $fontSource = Join-Path $RepoRoot "windows\fonts"
    $fontTarget = "$env:WINDIR\Fonts"

    if (-not (Test-Path $fontSource)) {
        Write-Error "Font source folder not found: $fontSource"
        return
    }

    Write-Host "[SemperFix] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
    Get-ChildItem $fontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } | ForEach-Object {
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
    }

    Write-Host "[SemperFix] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

    $Shell       = New-Object -ComObject Shell.Application
    $FontsFolder = $Shell.NameSpace($fontTarget)

    Get-ChildItem -Path $fontSource -Filter *.ttf | ForEach-Object {
        $fontFile = $_.FullName
        Write-Host "Installing font: $($_.Name)"
        Copy-Item $fontFile $fontTarget -Force
        $FontsFolder.CopyHere($fontFile, 0x10)
    }

    Write-Host "[SemperFix] Refreshing DirectWrite cache..." -ForegroundColor Yellow
    try {
        rundll32.exe "C:\Windows\System32\fntcache.dll",FontCache
    } catch {
        Write-Warning "[SemperFix] Could not refresh DirectWrite cache."
    }

    Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete." -ForegroundColor Green
}
