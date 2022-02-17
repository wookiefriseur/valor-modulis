[![CodeFactor](https://www.codefactor.io/repository/github/wookiefriseur/valor-modulis/badge)](https://www.codefactor.io/repository/github/wookiefriseur/valor-modulis)

# About
Collection of Powershell modules and scripts for everyday tasks. Use at your own risk.

# Installation

## Using Scoop
Add this repository as a bucket:
`scoop bucket add valor-modulis https://github.com/wookiefriseur/valor-modulis`

Install a module:
`scoop install HashUtils`

You can specify the bucket so scoop knows what to install exactly:
`scoop install valor-modulis/HashUtils`

It is symlinked automatically to a scoop directory that is in `$ENV:PSModulePath`.
Autoimport should work when you try to use a function (for instance `Get-Hash "Hallo"`).
If it does not work automatically, try to use `Import-Module Get-Hash`.

### If you don't have Scoop yet
```powershell
Invoke-Expression (New-Object net.webclient).DownloadString('https://get.scoop.sh')
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Manually
After cloning the repository you can add the functions to the current terminal session through:
* dot sourcing: `. script.ps1`
* import if it's a module: `Import-Module Module-Name.psm1`

For persistent scripts, load them in your psprofile.
For automatic module import, put it into one of your `$ENV:PSModulePath`.
Use prefixes in case of naming conflicts.


# Uninstalling

## Scoop
Uninstall providing the Module name.
`scoop uninstall Get-Hash`

If you want to also get rid of the bucket:
`scoop bucket rm valor-modulis`

## Manually
`Remove-Module Get-Hash`
