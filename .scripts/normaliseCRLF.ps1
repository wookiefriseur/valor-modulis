$basePath = Join-Path $PSScriptRoot "..\"
$gitattributesRoot = Join-Path $basePath ".gitattributes"

$submodules = Get-Content (Join-Path $basePath ".gitmodules") | Where-Object { $_ -match 'path' } | ForEach-Object { ($_ -split '=' | Select-Object -Last 1 | Out-String).Trim()  }

$submodules | ForEach-Object {
    $submodulePath = $_
    Write-Output "Processing $submodulePath"

    $gitattributesSubmodule = Join-Path $submodulePath ".gitattributes"

    if (-not (Test-Path $gitattributesSubmodule)) {
        Write-Output "Copying .gitattributes to $submodulePath"
        Copy-Item $gitattributesRoot $gitattributesSubmodule
    }

    Push-Location $submodulePath
    git add --renormalize .
    Pop-Location
}

Push-Location $basePath
Write-Output "Renormalising root repo"
git add --renormalize .
Pop-Location
