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
    )

    begin {
        $PSManifestDir = (Resolve-Path $PSManifestDir) -replace '[\\/]$', ''
        $ScoopManifestDir = (Resolve-Path $ScoopManifestDir) -replace '[\\/]$', ''
        Write-Verbose "Inputs:`n$($PSManifestDir)`n$($ScoopManifestDir)"
        $psManifestFile = (Get-ChildItem -Path $PSManifestDir -Filter  *.psd1)[0]
        $scoopManifestFile = "$ScoopManifestDir\$($psManifestFile.BaseName.ToLower()).json";

        # Pass only relevant information from the PS Manifest
        function ParseInfoFromManifest {
            $parsed = Import-PowerShellDataFile $psManifestFile
            $result = @{
                'homepage'    = "$($parsed.PrivateData.PSData.ProjectUri -replace '/$', '')"
                'description' = "$($parsed.Description)"
                'version'     = "$($parsed.ModuleVersion)"
                'license'     = "$($parsed.Copyright)"
            }
            Write-Verbose "Parsed from PSManifest:`n$($result | ConvertTo-Json)"
            return $result
        }

        function UpdateScoopManifest {
            $scoopManifest = @{
                'homepage'    = ''
                'description' = ''
                'version'     = ''
                'license'     = ''
                'psmodule'    = @{
                    'name' = ''
                }
                'url'         = @()
                'hash'        = @()
            }
            $psManifest = ParseInfoFromManifest

            $scoopManifest.homepage = $psManifest.homepage
            $scoopManifest.description = $psManifest.description
            $scoopManifest.version = $psManifest.version
            $scoopManifest.license = $psManifest.license
            $scoopManifest.psmodule.name = $psManifestFile.BaseName

            foreach ($file in (Get-ChildItem -Recurse -Path $PSManifestDir -File)) {
                $fileHash = git hash-object $file
                $scoopManifest.hash += $fileHash
                $baseFileDir = $file.Directory.FullName.Replace($PSManifestDir, '').Replace('\', '/')
                # Example: "https://raw.githubusercontent.com/wookiefriseur/valor-modulis/master/psmodules/NumberConverter/NumberConverter.psd1",
                $fileUrl = "$($scoopManifest.homepage)/raw/main$baseFileDir/$($file.BaseName)$($file.Extension)"
                # Example: https://github.com/wookiefriseur/ps_numberconverter/raw/main/NumberConverter.psd1
                $scoopManifest.url += $fileUrl

                Write-Verbose "Generating hash and url for $($file):`n$($fileHash)`n$($fileUrl)"
            }

            $scoopManifestJson = ($scoopManifest | ConvertTo-Json)
            Write-Verbose -Message "Creating scoop manifest for $($scoopManifest.name)"
            if ($PSCmdlet.ShouldProcess($scoopManifestFile, "Create/Overwrite file")) {
                New-Item -Force -Path $scoopManifestFile -Value "$scoopManifestJson`n" > $null
            }
        }
    }

    process {
        UpdateScoopManifest
    }

    end {
    }
}
