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


<#
.SYNOPSIS
   Convert a number from decimal to binary format.

.DESCRIPTION
    Returns a binary representation of a number from a decimal input.

.EXAMPLE
    ConvertTo-Binary -Value 42 -Prefixed -NoGrouping

.EXAMPLE
    ConvertTo-Binary -Value 42

.EXAMPLE
    ConvertTo-Binary 42

.EXAMPLE
    ConvertTo-Binary 0d42

.EXAMPLE
    42 | ConvertTo-Binary

.EXAMPLE
    @(42, -42, "0d42") | ConvertTo-Binary
#>
function ConvertTo-Binary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline = $true)]
        [System.String]
        $Value,
        # Activate prefix '0b'
        [switch]
        [bool]
        $Prefixed,
        # Disable spaces between groups of 4
        [switch]
        [bool]
        $NoGrouping
    )

    begin {

        function toBinaryString {
            $result = [System.Convert]::ToString( (getDecimal $Value), 2)

            if (-Not $NoGrouping) {
                $groups = ($result.PadLeft([decimal]::Ceiling($result.Length / 4) * 4, "0") -split "(\d{4})")
                $result = ($groups | Join-String -Separator " ")
            }

            if ($Prefixed) { $result = "0b$result" }

            return $result
        }

    }

    process {

        toBinaryString
    }

    end {
    }
}

<#
.SYNOPSIS
   Convert a number from octal to decimal format.

.DESCRIPTION
    Returns a decimal representation of a number from an octal input.
    It is assumed that the input is unsigned and Int64 by default.

.EXAMPLE
    ConvertFrom-Octal -Value 052

.EXAMPLE
    ConvertFrom-Octal -Format Int64 -Value 052

.EXAMPLE
    ConvertFrom-Octal -Format Int16 -Value "177 726"

.EXAMPLE
    ConvertFrom-Octal -Format UInt16 -Value "177 726"

.EXAMPLE
    ConvertFrom-Octal 052

.EXAMPLE
    ConvertFrom-Octal 0o52

.EXAMPLE
    052 | ConvertFrom-Octal

.EXAMPLE
    @(052, 52, "0o052") | ConvertFrom-Octal
#>
function ConvertFrom-Octal {
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

        function getOctalString {
            return $Value -replace "(0o)|\s", ""
        }

        function toInt {
            return [System.Convert]::"To$Format"( (getOctalString), 8)
        }

    }

    process {

        toInt
    }

    end {
    }
}

<#
.SYNOPSIS
   Convert a number from decimal to octal format.

.DESCRIPTION
    Returns an octal representation of a number from a decimal input.

.EXAMPLE
    ConvertTo-Octal -Value 42 -Prefixed -NoGrouping

.EXAMPLE
    ConvertTo-Octal -Value 42

.EXAMPLE
    ConvertTo-Octal 42

.EXAMPLE
    ConvertTo-Octal "0d42"

.EXAMPLE
    "42" | ConvertTo-Octal

.EXAMPLE
    @("42", 42, "0d42") | ConvertTo-Octal
#>
function ConvertTo-Octal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline = $true)]
        [System.String]
        $Value,
        # Activate prefix '0o'
        [switch]
        [bool]
        $Prefixed,
        # Disable spaces between groups of 3
        [switch]
        [bool]
        $NoGrouping
    )

    begin {

        function toOctalString {
            $result = [System.Convert]::ToString( (getDecimal $Value), 8)

            if (-Not $NoGrouping) {
                $groups = ($result.PadLeft([decimal]::Ceiling($result.Length / 3) * 3, "0") -split "(\d{3})")
                $result = ($groups | Join-String -Separator " ")
            }

            if ($Prefixed) { $result = "0o$result" }

            return $result
        }

    }

    process {

        toOctalString
    }

    end {
    }
}


<# Private helper functions for the module #>
function getDecimal([string] $decimalString) {
    return [System.Convert]::ToDecimal( ($decimalString -replace "0d", ""))
}
