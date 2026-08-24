function Repair-PoshFont {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Repairing JetBrainsMono Nerd Font..." -ForegroundColor Cyan

    $IsWSL = $false
    if ($env:WSL_DISTRO_NAME) { $IsWSL = $true }

    $ConfigPathWin = Join-Path $env:USERPROFILE ".semperfix-omp.json"
    $ConfigPathWSL = "$HOME/.semperfix-omp.json"

    $RepoRoot = $null

    if (-not $IsWSL -and (Test-Path $ConfigPathWin)) {
        $RepoRoot = (Get-Content $ConfigPathWin | ConvertFrom-Json).RepoRoot
    }

    if ($IsWSL -and (Test-Path $ConfigPathWSL)) {
        $RepoRoot = (Get-Content $ConfigPathWSL | ConvertFrom-Json).RepoRoot
    }

    if (-not $RepoRoot) {
        $moduleRoot = Split-Path $PSScriptRoot -Parent
        $RepoRoot   = Split-Path $moduleRoot -Parent
        Write-Warning "[SemperFix] Falling back to module-relative RepoRoot: $RepoRoot"
    }

    $FontSource = Join-Path $RepoRoot "windows/fonts"

    if (-not (Test-Path $FontSource)) {
        Write-Error "[SemperFix] Font source folder not found: $FontSource"
        return
    }

    if (-not $IsWSL) {
        $FontTarget = "$env:WINDIR\Fonts"

        Write-Host "[SemperFix] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
        Get-ChildItem $FontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } |
            Remove-Item -Force -ErrorAction SilentlyContinue

        Write-Host "[SemperFix] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

        $Shell       = New-Object -ComObject Shell.Application
        $FontsFolder = $Shell.NameSpace($FontTarget)

        Get-ChildItem -Path $FontSource -Filter *.ttf | ForEach-Object {
            Copy-Item $_.FullName $FontTarget -Force
            $FontsFolder.CopyHere($_.FullName, 0x10)
        }

        rundll32.exe "C:\Windows\System32\fntcache.dll",FontCache
        Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete." -ForegroundColor Green
        return
    }

    $WSLFontTarget = "$HOME/.local/share/fonts"
    mkdir $WSLFontTarget -Force | Out-Null

    $WSLFontSource = wslpath -a -u $FontSource

    cp "$WSLFontSource/*.ttf" "$WSLFontTarget/" 2>$null
    fc-cache -f

    Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete (WSL)." -ForegroundColor Green
}
