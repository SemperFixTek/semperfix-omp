function Test-SemperFixOMP {
    Write-Host "=== SemperFix-OMP Health Check ===" -ForegroundColor Cyan

    $ModuleName = "SemperFix.OMP"

    Write-Host "`n[1] Module Load Test" -ForegroundColor Yellow
    try {
        Import-Module $ModuleName -Force
        Write-Host "✔ Module loaded successfully"
    } catch {
        Write-Host "✘ Module failed to load" -ForegroundColor Red
        return
    }

    Write-Host "`n[2] Public Function Check" -ForegroundColor Yellow
    $Public = @(
        "Get-PoshTheme",
        "Get-PoshThemes",
        "Select-PoshTheme",
        "Set-PoshTheme",
        "Repair-PoshFont",
        "Sync-PoshFontWSL",
        "Test-SemperFixFont"
    )

    foreach ($fn in $Public) {
        if (Get-Command $fn -ErrorAction SilentlyContinue) {
            Write-Host "✔ $fn"
        } else {
            Write-Host "✘ $fn missing" -ForegroundColor Red
        }
    }

    Write-Host "`n[3] Alias Check" -ForegroundColor Yellow
    $Aliases = @("gpt","spt","ppt","rpf","spf")
    foreach ($a in $Aliases) {
        if (Get-Alias $a -ErrorAction SilentlyContinue) {
            Write-Host "✔ alias $a"
        } else {
            Write-Host "✘ alias $a missing" -ForegroundColor Red
        }
    }

    Write-Host "`n[4] RepoRoot Config Check" -ForegroundColor Yellow
    $ConfigPath = "$env:USERPROFILE\.semperfix-omp.json"
    if (Test-Path $ConfigPath) {
        $cfg = Get-Content $ConfigPath | ConvertFrom-Json
        Write-Host "✔ RepoRoot: $($cfg.RepoRoot)"
    } else {
        Write-Host "✘ RepoRoot config missing" -ForegroundColor Red
    }

    Write-Host "`n[5] Theme Directory Check" -ForegroundColor Yellow
    $ThemeDir = "$HOME/.poshthemes"
    if (Test-Path $ThemeDir) {
        Write-Host "✔ Theme directory exists"
    } else {
        Write-Host "✘ Theme directory missing" -ForegroundColor Red
    }

    Write-Host "`n[6] Font Directory Check" -ForegroundColor Yellow
    $FontDir = "$HOME/.local/share/fonts"
    if (Test-Path $FontDir) {
        Write-Host "✔ WSL font directory exists"
    } else {
        Write-Host "✘ WSL font directory missing" -ForegroundColor Red
    }

    Write-Host "`n[7] WSL Loader Check" -ForegroundColor Yellow
    $WSLLoader = "$HOME/.poshloader"
    if (Test-Path $WSLLoader) {
        Write-Host "✔ WSL loader installed"
    } else {
        Write-Host "✘ WSL loader missing" -ForegroundColor Red
    }

    Write-Host "`n=== Health Check Complete ===" -ForegroundColor Green
}
