@{
    RootModule        = 'SemperFix.OMP.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b7a3c1c4-2f6a-4b8e-9a9d-4e1b9f0c9d11'
    Author            = 'Bruce (SemperFix)'
    CompanyName       = 'SemperFix'
    Description       = 'SemperFix cross-system Oh My Posh theme sync module.'

    PowerShellVersion = '5.1'
    CompatiblePSEditions = @(
        'Core',
        'Desktop'
    )

    FunctionsToExport = @(
        'Get-PoshTheme',
        'Set-PoshTheme',
        'Select-PoshTheme'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @(
        'spt',
        'gpt',
        'cpt'
    )

    PrivateData = @{
        PSData   = @{
            Tags   = @(
                'OhMyPosh',
                'SemperFix',
                'Prompt',
                'Theme',
                'WSL',
                'Sync'
            )
        }
    }
}
