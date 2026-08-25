function Sync-PoshFontWSL {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Syncing fonts to WSL..." -ForegroundColor Cyan

    # Use WSL's login shell so ~/.bashrc or ~/.zshrc is sourced automatically
    $cmd = "sync_fonts"

    try {
        # -e ensures the correct shell is used
        # -l ensures login shell (sources .bashrc / .zshrc)
        $result = wsl -e bash -lc $cmd
    }
    catch {
        Write-Error "[SemperFix] WSL font sync failed: $_"
        return
    }

    if ($null -ne $result -and $result.Trim() -ne "") {
        Write-Host $result
    }

    Write-Host "[SemperFix] WSL font sync complete." -ForegroundColor Green
}
