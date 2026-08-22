function Sync-PoshFontWSL {
    Write-Host "[SemperFix] Syncing fonts to WSL..." -ForegroundColor Yellow
    wsl sync_fonts
    Write-Host "WSL font sync complete." -ForegroundColor Green
}
