[![CodeFactor](https://www.codefactor.io/repository/github/wookiefriseur/valor-modulis/badge)](https://www.codefactor.io/repository/github/wookiefriseur/valor-modulis)

# About
Collection of Powershell modules and scripts for everyday tasks. Use at your own risk.

# Installation

## Using Scoop

* add this repository as a bucket
    * `scoop bucket add valor-modulis https://github.com/wookiefriseur/valor-modulis`
* install a module
    * `scoop install HashUtils`
    * `scoop install valor-modulis/HashUtils` (optional: specify bucket)
* the module is automatically symlinked to a scoop directory in `$ENV:PSModulePath`
    * autoimport should trigger when you try to use a function from a module (for instance `Get-Hash "Hallo"`)
    * try to use `Import-Module HashUtils` if autoimport fails

### If you don't have Scoop yet
```powershell
Invoke-Expression (New-Object net.webclient).DownloadString('https://get.scoop.sh')
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Manually
After cloning the repository you can add the functions to the current terminal session through:
* dot sourcing: `. script.ps1`
* import if it's a module: `Import-Module ModuleName.psm1`

For persistent scripts, load them in your psprofile.
For automatic module import, put it into one of your `$ENV:PSModulePath`.
Use prefixes in case of naming conflicts.


# Uninstalling

## Scoop

* Uninstall providing the Module name:
    * `scoop uninstall Get-Hash`
    * `scoop uninstall valor-modulis/Get-Hash` (optional: specify bucket)
* bucket can be removed as follows:
    * `scoop bucket rm valor-modulis`

## Manually

* `Remove-Module Get-Hash` (this will only unload a module)
* uninstall it in scoop for a more permanent solution
