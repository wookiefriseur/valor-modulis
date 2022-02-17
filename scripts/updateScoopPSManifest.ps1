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
    Update-ScoopPSManifest -ScoopManifestDir ".\bucket\" -PSManifestDir ".\psmodules\Get-Hash\" -Verbose -WhatIf
.EXAMPLE
    Update-ScoopPSManifest -PSManifestDir ".\psmodules\Get-Hash\" -ScoopManifestDir ".\bucket\" -NoNewlineReplace
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
        ,
        # Whether to reformat newlines in PSModule files
        [Parameter(Mandatory=$false)]
        [Switch]
        $NoNewlineReplace
    )

    begin {
        $psManifestFile = (Get-ChildItem -Path $PSManifestDir -Filter  *.psd1)[0]
        $scoopManifestFile = "$ScoopManifestDir\$($psManifestFile.BaseName).json";

        # Reformat module files to newline=lf
        function ReplaceNewlines {
            if ($NoNewlineReplace) { return }

            $psFiles = (Get-ChildItem -Path $PSManifestDir -Recurse -Filter *.ps*1 -ErrorAction SilentlyContinue)
            $psFiles = $psFiles | Where-Object { $_.Extension -eq '.psd1' -or $_.Extension -eq '.psm1' }
            foreach ($psFile in $psFiles) {
                if ($PSCmdlet.ShouldProcess($psFile, "Edit file")) {
                    Write-Verbose "Replacing cr+lf in $($psFile.Name)"
                    $fileContent = (Get-Content -Path $psFile -Encoding utf8 -Raw).Replace("`r`n", "`n")
                    New-Item -Force -Path $psFile -Value $fileContent > $null
                }
            }
        }

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
            ReplaceNewlines
            $psManifest = GetInfoFromPSManifest
            $scoopManifest = GetInfoFromScoopManifest

            $scoopManifest.version = $psManifest.version
            $scoopManifest.description = $psManifest.description

            for ($i = 0; $i -lt $scoopManifest.url.Count; $i++) {
                $scoopManifest.url[$i] -match '\/(?<Name>[\w\-]+\.\w+$)' > $null
                $file = $Matches.Name
                $scoopManifest.hash[$i] = (Get-FileHash "$PSManifestDir\$file").Hash.ToLower()
            }

            $scoopManifestJson = ($scoopManifest | ConvertTo-Json).Replace("`r`n", "`n")
            Write-Verbose -Message "Scoop manifest before:`n$(Get-Content -Raw $scoopManifestFile)"
            Write-Verbose -Message "Scoop manifest after:`n$scoopManifestJson"
            if ($PSCmdlet.ShouldProcess($scoopManifestFile, "Create/Overwrite file")) {
                New-Item -Force -Path $scoopManifestFile -Value "$scoopManifestJson`n"
            }
        }
    }

    process {
        UpdateScoopManifest
    }

    end {
    }
}
