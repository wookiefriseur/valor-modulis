<#
.SYNOPSIS
    Generate Hashes from Strings

.DESCRIPTION
    Create hashes from Strings, similar to Get-FileHash.
    The default method is SHA1, encoding is UTF-8.

.EXAMPLE
    Get-Hash -Text "Hello world" -Method SHA1

.EXAMPLE
    Get-Hash "Hello world"

.EXAMPLE
    "Hello world" | Get-Hash

.EXAMPLE
    @("A", "B", "C") | Get-Hash
#>
function Get-Hash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline = $true)]
        [System.String]
        $Text
        ,
        # Set of currently supported hashing algorithms
        [ValidateSet("SHA1", "SHA256", "MD5")]
        [System.String]
        $Method = "SHA1"
        ,
        # Switch between lower and upper case display mode, if the hash is case insensitive
        [Parameter()]
        [Switch]
        $UpperCase
    )

    begin {

        function GenerateMD5 {
            $md5Generator = New-Object System.Security.Cryptography.MD5CryptoServiceProvider
            $hashFormat = if ($UpperCase) { "X2" } else { "x2" }
            $textBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
            $hashByteArray = $md5Generator.ComputeHash($textBytes)

            return bytesToString $hashByteArray $hashFormat (128 / 4)
        }

        function GenerateSHA1 {
            $sha1Generator = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
            $hashFormat = if ($UpperCase) { "X2" } else { "x2" };
            $textBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
            $hashByteArray = $sha1Generator.ComputeHash($textBytes)

            return bytesToString $hashByteArray $hashFormat (160 / 4)
        }

        function GenerateSHA256 {
            $sha256Generator = New-Object System.Security.Cryptography.SHA256Managed
            $hashFormat = if ($UpperCase) { "X2" } else { "x2" }
            $textBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
            $hashByteArray = $sha256Generator.ComputeHash($textBytes)

            return bytesToString $hashByteArray $hashFormat (256 / 4)
        }

        function bytesToString ([byte[]] $bytes, [String] $format, [int] $capacity) {
            $result = [System.Text.StringBuilder]::new($capacity)
            foreach ($byte in $bytes) {
                $result.Append(([Byte]$byte).ToString($format)) > $null
            }
            return $result.ToString()
        }

        function GenerateUnknown {
            throw New-Object System.NotImplementedException
        }

    }

    process {

        try {
            switch ($Method) {
                { $_ -eq "MD5" } { return GenerateMD5 }
                { $_ -eq "SHA1" } { return GenerateSHA1 }
                { $_ -eq "SHA256" } { return GenerateSHA256 }
                Default { return GenerateUnknown }
            }
        }
        catch [System.NotImplementedException] {
            Write-Error "$Method : $($Error[0])"
        }
    }

    end {
    }
}
