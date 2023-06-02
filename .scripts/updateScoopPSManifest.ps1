<#
.SYNOPSIS
    Create or update a Scoop Manifest for a psmodule

.DESCRIPTION
    Updates a scoop manifest file using data inside the powershell manifest file.
    Generates normalised file hashes (with LF line endings).

.EXAMPLE
    Update-ScoopPSManifest ".\psmodules\Get-Hash\" ".\bucket\"
.EXAMPLE
    Update-ScoopPSManifest -ScoopManifestDir ".\bucket\" -PSManifestDir ".\psmodules\Get-Hash\"
.EXAMPLE
    Update-ScoopPSManifest -ScoopManifestDir ".\bucket\" -PSManifestDir ".\psmodules\Get-Hash\" -ScoopManifestPrefix "xxx_"
.EXAMPLE
    Update-ScoopPSManifest -ScoopManifestDir ".\bucket\" -PSManifestDir ".\psmodules\Get-Hash\" -Verbose -WhatIf
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
        # Prefix of the scoop manifest json (json name will be the application name in scoop)
        [Parameter(Position = 3)]
        [System.String]
        $ScoopManifestPrefix = "vm_"
    )

    begin {
        $PSManifestDir = (Resolve-Path $PSManifestDir) -replace '[\\/]$', ''
        $ScoopManifestDir = (Resolve-Path $ScoopManifestDir) -replace '[\\/]$', ''
        Write-Verbose "Inputs:`n$($PSManifestDir)`n$($ScoopManifestDir)"
        $psManifestFile = (Get-ChildItem -Path $PSManifestDir -Filter  *.psd1)[0]
        $scoopManifestFile = "$ScoopManifestDir\$ScoopManifestPrefix$($psManifestFile.BaseName.ToLower()).json";

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

        function GetHashOfNormalisedFile($filePath) {
            $fileContent = (Get-Content -Raw $filePath).Replace("`r",'')
            $byteContent = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
            $hash = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256").ComputeHash($byteContent)
            $hashString = [BitConverter]::ToString($hash).Replace('-','')
            return $hashString.ToLower()
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

            $extensions = @('*.psd1', '*.psm1', '*.ps1', '*.txt')
            foreach ($file in (Get-ChildItem -Recurse -Path $PSManifestDir -File -Include $extensions)) {
                $fileHash = GetHashOfNormalisedFile $file
                $scoopManifest.hash += $fileHash
                $baseFileDir = $file.Directory.FullName.Replace($PSManifestDir, '').Replace('\', '/')
                # Example: "https://github.com/wookiefriseur/ps_numberconverter/raw/main/NumberConverter.psm1",
                $fileUrl = "$($scoopManifest.homepage)/raw/main$baseFileDir/$($file.BaseName)$($file.Extension)"
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
