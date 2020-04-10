## Just replace where it says "WindowsUpdate" with the name of the module that you want to check for.

if (Get-Module -ListAvailable -Name WindowsUpdate) {
    Write-Host "Module exists"
} 
else {
    Write-Host "Module does not exist"
}

Read-Host -Prompt "Press Enter to exit"
