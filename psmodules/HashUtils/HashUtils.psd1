@{
    RootModule        = 'HashUtils.psm1'
    ModuleVersion     = '2.0.0'
    Description       = 'Offers utility commandlets for hashing'

    GUID              = 'd470a933-496d-44b7-b5c2-e614c9046332'

    Author            = 'Matthäus Falkowski'
    Copyright         = 'Copyright (c) 2022 Matthäus Falkowski. MIT License.'

    # Exports
    FunctionsToExport = @('Get-Hash')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{

        PSData = @{

            Tags       = @('hash')
            ProjectUri = 'https://github.com/wookiefriseur/ps_hashutils/'
            LicenseUri = 'https://github.com/wookiefriseur/valor-modulis/blob/master/LICENSE.md'
        }

    }

}
