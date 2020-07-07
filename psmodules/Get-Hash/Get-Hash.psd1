@{
    RootModule         = 'Get-Hash.psm1'
    ModuleVersion      = '1.0.0'
    Description        = 'Offers utility commandlets for generating hashes'

    GUID               = 'd470a933-496d-44b7-b5c2-e614c9046332'

    Author             = 'Matthäus Falkowski'
    Copyright          = 'Copyright (c) 2020 Matthäus Falkowski. MIT License.'

    # Exports
    FunctionsToExport  = ''
    CmdletsToExport    = 'Get-Hash'
    VariablesToExport  = ''
    AliasesToExport    = ''

    # Dependencies
    #RequiredAssemblies = @()

    PrivateData        = @{

        PSData = @{

            Tags = @("hash")
            LicenseUri = "https://github.com/wookiefriseur/valor-modulis/blob/master/LICENSE.md"
        }

    }

    # Override the default prefix using Import-Module -Prefix.
    #DefaultCommandPrefix = 'Mat'

}
