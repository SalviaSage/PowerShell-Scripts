## This will uninstall a specific version of a specific module
## It is also possible to check if a module is instaled or to check for a specific version of a module using commands.

Get-Package -Name "DSCAccelerator" -RequiredVersion "2.1" | Uninstall-Package
