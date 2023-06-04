function getNextVersion($currentVersion, $impact = 'patch') {
    $semver = $currentVersion.Split('.')
    $major = [int]($semver[0])
    $minor = [int]($semver[1])
    $patch = [int]($semver[2])

    if ($impact -eq 'major') {
        $major+=1
        $minor=0
        $patch=0
    } elseif ($impact -eq 'minor') {
        $minor+=1
        $patch=0
    } else {
        $patch+=1
    }

    return "$($major).$($minor).$($patch)"
}

function Update-PSManifestVersion($manifestFile, $impact = 'patch') {
    $manifestData = Import-PowerShellDataFile -Path $manifestFile
    $currentVersion = $manifestData.ModuleVersion
    $nextVersion = getNextVersion $currentVersion $impact

    $manifestData.ModuleVersion = $nextVersion

    Update-ModuleManifest -Path $manifestFile -ModuleVersion $nextVersion
    return $nextVersion
}
