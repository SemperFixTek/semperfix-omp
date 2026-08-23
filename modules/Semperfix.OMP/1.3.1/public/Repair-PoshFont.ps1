function Repair-PoshFont {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Repairing JetBrainsMono Nerd Font..." -ForegroundColor Cyan

    # ------------------------------------------------------------
    # Detect Windows vs WSL
    # ------------------------------------------------------------
    $IsWSL = $false
    if ($env:WSL_DISTRO_NAME) { $IsWSL = $true }

    # ------------------------------------------------------------
    # Load RepoRoot from installer config (Windows + WSL)
    # ------------------------------------------------------------
    $ConfigPathWin = Join-Path $env:USERPROFILE ".semperfix-omp.json"
    $ConfigPathWSL = "$HOME/.semperfix-omp.json"

    $RepoRoot = $null

    if (-not $IsWSL -and (Test-Path $ConfigPathWin)) {
        try {
            $RepoRoot = (Get-Content $ConfigPathWin | ConvertFrom-Json).RepoRoot
        } catch {
            Write-Warning "[SemperFix] Could not read RepoRoot from Windows config."
        }
    }

    if ($IsWSL -and (Test-Path $ConfigPathWSL)) {
        try {
            $RepoRoot = (Get-Content $ConfigPathWSL | ConvertFrom-Json).RepoRoot
        } catch {
            Write-Warning "[SemperFix] Could not read RepoRoot from WSL config."
        }
    }

    # ------------------------------------------------------------
    # Fallback: derive repo root from module path
    # ------------------------------------------------------------
    if (-not $RepoRoot) {
        $moduleRoot = Split-Path $PSScriptRoot -Parent
        $RepoRoot   = Split-Path $moduleRoot -Parent
        Write-Warning "[SemperFix] Falling back to module-relative RepoRoot: $RepoRoot"
    }

    # ------------------------------------------------------------
    # Resolve font source (repo-aware)
    # ------------------------------------------------------------
    $FontSource = Join-Path $RepoRoot "windows/fonts"

    if (-not (Test-Path $FontSource)) {
        Write-Error "[SemperFix] Font source folder not found: $FontSource"
        return
    }

    # ------------------------------------------------------------
    # Windows mode
    # ------------------------------------------------------------
    if (-not $IsWSL) {
        $FontTarget = "$env:WINDIR\Fonts"

        Write-Host "[SemperFix] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
        Get-ChildItem $FontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } | ForEach-Object {
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        }

        Write-Host "[SemperFix] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

        $Shell       = New-Object -ComObject Shell.Application
        $FontsFolder = $Shell.NameSpace($FontTarget)

        Get-ChildItem -Path $FontSource -Filter *.ttf | ForEach-Object {
            $fontFile = $_.FullName
            Write-Host "Installing font: $($_.Name)"
            Copy-Item $fontFile $FontTarget -Force
            $FontsFolder.CopyHere($fontFile, 0x10)
        }

        Write-Host "[SemperFix] Refreshing DirectWrite cache..." -ForegroundColor Yellow
        try {
            rundll32.exe "C:\Windows\System32\fntcache.dll",FontCache
        } catch {
            Write-Warning "[SemperFix] Could not refresh DirectWrite cache."
        }

        Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete." -ForegroundColor Green
        return
    }

    # ------------------------------------------------------------
    # WSL mode
    # ------------------------------------------------------------
    if ($IsWSL) {
        Write-Host "[SemperFix] WSL detected — syncing fonts into ~/.local/share/fonts" -ForegroundColor Yellow

        $WSLFontTarget = "$HOME/.local/share/fonts"
        if (-not (Test-Path $WSLFontTarget)) {
            mkdir $WSLFontTarget | Out-Null
        }

        # Convert Windows repo path to WSL path
        $WSLFontSource = wslpath -a -u $FontSource

        Write-Host "[SemperFix] Copying fonts from: $WSLFontSource"
        Write-Host "[SemperFix] To: $WSLFontTarget"

        cp "$WSLFontSource/*.ttf" "$WSLFontTarget/" 2>$null

        Write-Host "[SemperFix] Refreshing WSL font cache..." -ForegroundColor Yellow
        fc-cache -f

        Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete (WSL)." -ForegroundColor Green
        return
    }
}
