@{
    RootModule        = 'Update-ScoopPSManifest.psm1'
    ModuleVersion     = '0.1.0'
    Description       = 'Update Scoop bucket manifest with info from ps module manifest'

    GUID              = '7e5d122c-b60b-4985-8a51-769ba5c791ba'

    Author            = 'Matthäus Falkowski'
    Copyright         = 'Copyright (c) 2020 Matthäus Falkowski. MIT License.'

    # Exports
    FunctionsToExport = @("Update-ScoopPSManifest")
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{

        PSData = @{

            Tags       = @("scoop", "manifest")
            LicenseUri = "https://github.com/wookiefriseur/valor-modulis/blob/master/LICENSE.md"
        }

    }

}
