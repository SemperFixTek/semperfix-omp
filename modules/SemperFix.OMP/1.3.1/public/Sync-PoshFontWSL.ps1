function Sync-PoshFontWSL {
    Write-Host "[SemperFix] Syncing fonts to WSL..." -ForegroundColor Cyan

    $cmd = "cd ~ && source ~/.poshloader && sync_fonts"
    $result = wsl bash -c "$cmd"

    Write-Host $result
    Write-Host "WSL font sync complete."
}
