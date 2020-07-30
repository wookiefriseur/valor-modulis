<#
.SYNOPSIS
   Convert a number from binary to decimal format.

.DESCRIPTION
    Returns a decimal representation of a number from a binary input.
    It is assumed that the input is unsigned and Int64 by default.

.EXAMPLE
    ConvertFrom-Binary -Value "0010 1010"

.EXAMPLE
    ConvertFrom-Binary -Format Int64 -Value "1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1101 0110"

.EXAMPLE
    ConvertFrom-Binary -Format Int16 -Value "1111 1111 1101 0110"

.EXAMPLE
    ConvertFrom-Binary -Format UInt16 -Value "1111 1111 1101 0110"

.EXAMPLE
    ConvertFrom-Binary 101010

.EXAMPLE
    ConvertFrom-Binary 0b101010

.EXAMPLE
    "0010 1010" | ConvertFrom-Binary

.EXAMPLE
    @("0010 1010", 101010, 0b101010) | ConvertFrom-Binary
#>
function ConvertFrom-Binary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline = $true)]
        [System.String]
        $Value,
        # Target format of the conversion
        [ValidateSet("Int16", "Int32", "Int64", "UInt16", "UInt32", "UInt64")]
        [System.String]
        $Format = "UInt64"
    )

    begin {

        function getBinaryString {
            return $Value -replace "(0b)|\s", ""
        }

        function toInt {
            return [System.Convert]::"To$Format"( (getBinaryString), 2)
        }

    }

    process {

        toInt
    }

    end {
    }
}
