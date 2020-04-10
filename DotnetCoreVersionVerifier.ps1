# Got the ideas from here, but not using dotnet.exe --info or dotnet.exe --version and parsing its output
# http://irisclasson.com/2017/06/27/net-core-finding-out-sdk-installed-runtime-and-framework-host-versions/
# We're only dealing with Windows platform here and not linux and only packages using the installer method
# will be detected. Zip packages will not be handled

Function Get-InstalledDotnetCoreVersion
{
		[CmdletBinding()]
		[OutputType([PSObject])]
		param()

		[Hashtable] $SDKVersions = [ordered] @{}
		[Hashtable] $RuntimeVersions = [ordered] @{}
		[Hashtable] $FrameworkHostingVersions = [ordered] @{}
		[Hashtable] $ServerHostingBundleVersions = [ordered] @{}
		[Hashtable] $AspNetRuntimePackageStoreVersions = [ordered] @{}

		try
		{
				# Got the ideas from here, but not using dotnet.exe --info or dotnet.exe --version and parsing its output
				# http://irisclasson.com/2017/06/27/net-core-finding-out-sdk-installed-runtime-and-framework-host-versions/
				# We're only dealing with Windows platform here and not linux and only packages using the installer method
				# will be detected. Zip packages will not be handled

				[string] $RootDotnetPath = Join-Path -Path $env:programfiles -ChildPath 'dotnet'
				[string] $SdkPath = Join-Path -Path $RootDotnetPath -ChildPath 'sdk'
				[string] $RuntimePath = Join-Path -Path $RootDotnetPath -ChildPath 'shared\Microsoft.NETCore.App'
				[string] $SFHPath = Join-Path -Path $RootDotnetPath -ChildPath 'host\fxr'

				if (Test-Path -Path $RootDotnetPath -PathType Container)
				{
						if (Test-Path -Path $SdkPath -PathType Container)
						{
								Write-Verbose "$($SdkPath) was found. Enumerating versions now."

								Get-ChildItem -Path $SdkPath -Directory | Where-Object { $_.Name -match '^\d.\d.\d' } `
										| Sort-Object -Property Name | Foreach-Object { $SDKVersions.Add( $_.Name, $_.FullName ) }
						}

						if (Test-Path -Path $RuntimePath -PathType Container)
						{
								Write-Verbose "$($RuntimePath) was found. Enumerating versions now."

								Get-ChildItem -Path $RuntimePath -Directory | Where-Object { $_.Name -match '^\d.\d.\d' } `
										| Sort-Object -Property Name | Foreach-Object { $RuntimeVersions.Add( $_.Name, $_.FullName ) }
						}

						if (Test-Path -Path $SFHPath -PathType Container)
						{
								Write-Verbose "$($SFHPath) was found. Enumerating versions now."

								Get-ChildItem -Path $SFHPath -Directory | Where-Object { $_ -match '^\d.\d.\d' } `
										| Sort-Object -Property Name | Foreach-Object { $FrameworkHostingVersions.Add( $_.Name, $_.FullName ) }
						}
				}

				$ServerHostingBundleVersions = Get-InstalledDotnetCoreBundles -BundleName 'WindowsServerHosting'
				$AspNetRuntimePackageStoreVersions = Get-InstalledDotnetCoreBundles -BundleName 'ASPNetRuntimePackageStore'

				[Hashtable] $Properties = @{ 'SDKVersions' = $SDKVersions;
						'RuntimeVersions' = $RuntimeVersions;
						'SharedFrameworkHostingVersions' = $FrameworkHostingVersions;
						'WindowsServerHostingVersions' = $ServerHostingBundleVersions;
						'AspNetRuntimePackageStoreVersions' = $AspNetRuntimePackageStoreVersions
				}

				$Result = New-Object -TypeName PSObject -Prop $Properties

				return $Result
		}
		catch
		{
				throw $_
		}
}

Function Get-InstalledDotnetCoreBundles
{
		[CmdletBinding()]
		[OutputType([HashTable])]
		param(
				[Parameter(Mandatory = $true, HelpMessage = 'DotnetCore bundle name to search for')]
				[ValidateSet('WindowsServerHosting', 'ASPNetRuntimePackageStore')]
				[string]
				$BundleName
		)

		[HashTable] $InstalledVersion = [ordered] @{}
		[string] $RootPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Updates\.NET Core'
		[string] $PathFilter = ''

		try
		{
				switch ($BundleName)
				{
						'WindowsServerHosting' { $PathFilter = 'Microsoft .Net Core*Windows Server Hosting' }
						'ASPNetRuntimePackageStore' { $PathFilter = 'Microsoft ASP.NET Core*Runtime Package Store*' }
				}

				if (Test-Path -Path $RootPath -PathType Container)
				{
						[string[]] $InstalledSHBundles = Get-ChildItem -Path $RootPath `
								| Where-Object { $_.PSChildName -like $PathFilter } `
								| Sort-Object -Property PSChildName | Select-Object -ExpandProperty PSChildName
						
						for ($i = 0; $i -lt $InstalledSHBundles.Count; $i++)
						{
								if ($InstalledSHBundles[$i] -match '\d.\d.\d')
								{
										$InstalledVersion.Add($Matches[0], $InstalledSHBundles[$i])
								}
						}
				}
		}
		catch
		{
				throw $_
		}
		finally
		{
				Write-Output -InputObject $InstalledVersion -NoEnumerate
		}
}

$Results = Get-InstalledDotnetCoreVersion
$Results
pause
