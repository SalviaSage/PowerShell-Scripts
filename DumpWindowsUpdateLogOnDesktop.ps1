## Windows Update logs are now generated using ETW (Event Tracing for Windows).
## Please run the Get-WindowsUpdateLog PowerShell command to convert ETW traces into a readable WindowsUpdate.log.
## For more information, please visit https://go.microsoft.com/fwlink/?LinkId=518345

### This script does exactly that, it dumps the "WindowsUpdate.log" file on desktop.

Get-WindowsUpdateLog
