@{
    RootModule        = 'SemperFix.OMP.psm1'
    ModuleVersion     = '1.3.1'
    GUID              = 'c1b7e4e4-9f4a-4f8b-9c3e-1e3f1b3a131f'
    Author            = 'Bruce (SemperFix)'
    CompanyName       = 'SemperFix'
    Description       = 'SemperFix Oh My Posh integration module with repo-aware font repair, WSL sync, theme management, and diagnostics.'
    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        'Get-PoshTheme',
        'Get-PoshThemes',
        'Select-PoshTheme',
        'Set-PoshTheme',
        'Repair-PoshFont',
        'Sync-PoshFontWSL',
        'Test-SemperFixFont'
    )

    AliasesToExport = @(
        'gpt', 'spt', 'ppt', 'rpf', 'spf'
    )

    PrivateData = @{
        PSData = @{
            Tags        = @('SemperFix','OMP','WSL','Fonts','Themes')
            ProjectUri  = 'https://github.com/semperfix/semperfix-omp'
            ReleaseNotes = @'
v1.3.1
- RepoRoot config added
- Repair-PoshFont rewritten (Windows + WSL dual-mode)
- Sync-PoshFontWSL rewritten (UNC-safe)
- WSL loader updated
- Public/Private loader fixed
'@
        }
    }
}
