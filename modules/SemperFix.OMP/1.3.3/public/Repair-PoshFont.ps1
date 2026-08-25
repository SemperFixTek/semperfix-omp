function Repair-PoshFont {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Repairing JetBrainsMono Nerd Font..." -ForegroundColor Cyan

    # Detect WSL
    $isWSL = $null -ne $env:WSL_DISTRO_NAME

    # Load RepoRoot from config
    $configPathWin = Join-Path $env:USERPROFILE ".semperfix-omp.json"
    $configPathWSL = "$HOME/.semperfix-omp.json"

    $repoRoot = $null

    if (-not $isWSL -and (Test-Path $configPathWin)) {
        $repoRoot = (Get-Content $configPathWin | ConvertFrom-Json).RepoRoot
    }

    if ($isWSL -and (Test-Path $configPathWSL)) {
        $repoRoot = (Get-Content $configPathWSL | ConvertFrom-Json).RepoRoot
    }

    # Fallback: module-relative RepoRoot
    if ($null -eq $repoRoot) {
        $moduleRoot = Split-Path $PSScriptRoot -Parent
        $repoRoot   = Split-Path $moduleRoot -Parent
        Write-Warning "[SemperFix] Falling back to module-relative RepoRoot: $repoRoot"
    }

    # Resolve font source
    $fontSource = Join-Path $repoRoot "windows/fonts"

    if (-not (Test-Path $fontSource)) {
        Write-Error "[SemperFix] Font source folder not found: $fontSource"
        return
    }

    if (-not $isWSL) {
        # Windows mode
        $fontTarget = "$env:WINDIR\Fonts"

        Write-Host "[SemperFix] Removing old JetBrainsMono fonts..." -ForegroundColor Yellow
        Get-ChildItem $fontTarget |
            Where-Object { $_.Name -like "JetBrainsMono*" } |
            Remove-Item -Force -ErrorAction SilentlyContinue

        Write-Host "[SemperFix] Installing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

        $shell       = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.NameSpace($fontTarget)

        Get-ChildItem -Path $fontSource -Filter *.ttf | ForEach-Object {
            Copy-Item $_.FullName $fontTarget -Force
            $fontsFolder.CopyHere($_.FullName, 0x10)
        }

        try {
            rundll32.exe "C:\Windows\System32\fntcache.dll",FontCache
        }
        catch {
            Write-Warning "[SemperFix] Could not refresh DirectWrite cache."
        }

        Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete." -ForegroundColor Green

        return [PSCustomObject]@{
            Platform   = "Windows"
            RepoRoot   = $repoRoot
            FontSource = $fontSource
            FontTarget = $fontTarget
            Status     = "Success"
        }
    }

    # WSL mode
    $wslFontTarget = "$HOME/.local/share/fonts"
    if (-not (Test-Path $wslFontTarget)) {
        New-Item -ItemType Directory -Path $wslFontTarget | Out-Null
    }

    $wslFontSource = wslpath -a -u $fontSource

    # PowerShell-native copy
    Get-ChildItem -Path $wslFontSource -Filter *.ttf |
        ForEach-Object {
            Copy-Item $_.FullName $wslFontTarget -Force
        }

    fc-cache -f

    Write-Host "[SemperFix] JetBrainsMono Nerd Font repair complete (WSL)." -ForegroundColor Green

    return [PSCustomObject]@{
        Platform   = "WSL"
        RepoRoot   = $repoRoot
        FontSource = $wslFontSource
        FontTarget = $wslFontTarget
        Status     = "Success"
    }
}
