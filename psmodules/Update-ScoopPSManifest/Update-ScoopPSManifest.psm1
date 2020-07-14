<#
.SYNOPSIS
    Update an existing Scoop Manifest for a psmodule

.DESCRIPTION
    Updates a scoop manifest file using data inside
    the powershell manifest file and newly generated file hashes.
    The files must exist in the local directoy.

.EXAMPLE
    Update-ScoopPSManifest -PSManifestDir ".\psmodules\Get-Hash\" -ScoopManifestDir ".\bucket\"
.EXAMPLE
    Update-ScoopPSManifest -PSManifestDir ".\psmodules\Get-Hash\" -ScoopManifestDir ".\bucket\" -Verbose -WhatIf
#>
function Update-ScoopPSManifest {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Full or relative path of the powershell module
        [Parameter(Mandatory, Position = 1, ValueFromPipeline = $true)]
        [System.String]
        $PSManifestDir
        ,
        # Full or relative path of the scoop manifest bucket
        [Parameter(Mandatory, Position = 2, ValueFromPipeline = $true)]
        [System.String]
        $ScoopManifestDir
    )

    begin {
        $psManifestFile = (Get-ChildItem -Path $PSManifestDir -Filter  *.psd1)[0]
        $scoopManifestFile = "$ScoopManifestDir\$($psManifestFile.BaseName).json";

        # Pass only relevant information from the PS Manifest
        function GetInfoFromPSManifest {
            $parsed = Import-PowerShellDataFile $psManifestFile
            return @{version=$parsed.ModuleVersion; description=$parsed.Description}
        }

        # Scoop manifest must have the same name like the directory of the module
        function GetInfoFromScoopManifest {
            return ((Get-Content -Raw "$ScoopManifestDir\$($psManifestFile.BaseName).json") | ConvertFrom-Json)
        }

        function UpdateScoopManifest {
            $psManifest = GetInfoFromPSManifest
            $scoopManifest = GetInfoFromScoopManifest

            $scoopManifest.version = $psManifest.version
            $scoopManifest.description = $psManifest.description

            for ($i = 0; $i -lt $scoopManifest.url.Count; $i++) {
                $scoopManifest.url[$i] -match '\/(?<Name>[\w\-]+\.\w+$)' > $NULL
                $file = $Matches.Name
                $scoopManifest.hash[$i] = (Get-FileHash "$PSManifestDir\$file").Hash.ToLower()
            }

            $scoopManifestJson = ($scoopManifest | ConvertTo-Json)
            Write-Verbose -Message "Scoop manifest before:`n$(Get-Content -Raw $scoopManifestFile)"
            Write-Verbose -Message "Scoop manifest after:`n$scoopManifestJson"
            if ($PSCmdlet.ShouldProcess($scoopManifestFile, "Overwrite")) {
                New-Item -Force -Path $scoopManifestFile -Value $scoopManifestJson
            }
        }
    }

    process {
        UpdateScoopManifest
    }

    end {
    }
}
