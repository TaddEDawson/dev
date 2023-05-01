<#
	.SYNOPSIS
		Identify duplicate entries in web.config file
	.EXAMPLE 
		.\dedup.ps1
#>
[CmdletBinding()]
param
(
	$ConfigFile = ".\web.config"
) # param
process
{
	$VerbosePreference = "Continue"
	$ErrorActionPreference = "Stop"
	try
	{
		Write-Verbose ("Try scriptblock")
		# Load the XML file into a PowerShell variable
		[Xml] $webConfig = Get-Content $ConfigFile

		# How many assemblybindings?
		Write-Verbose ("`tThere are ({0}) dependentassemblies present in ({1})" -f $webConfig.configuration.runtime.assemblyBinding.dependentAssembly.Count, $ConfigFile)


		<#
			Looking to remove duplicate entries from runtime.
			e.g.

			<dependentAssembly>
				<assemblyIdentity name="System.Net.Http.Formatting" publicKeyToken="31bf3856ad364e35" culture="neutral" />
				<bindingRedirect oldVersion="0.0.0.0-5.2.3.0" newVersion="5.2.3.0" />
			</dependentAssembly>
		#>

		$dependentAssemblies = [System.Collections.ArrayList]::new()
		# Keep track of dependentAssembly(ies) that have been evaluated
		$webConfig.configuration.runtime.assemblyBinding.dependentAssembly | 
				ForEach-Object { 
					$processed = [PSCustomObject]@{
						name 				= $_.assemblyIdentity.name
						publicKeyToken 		= $_.assemblyIdentity.publicKeyToken
						culture 			= $_.assemblyIdentity.culture
						oldVersion			= $_.bindingRedirect.oldVersion
						newVersion			= $_.bindingRedirect.newVersion
					} # [PSCustomObject]
				
					$processed 
					
					if($dependentAssemblies.Count -eq 0)
					{
						Write-Verbose ("Add ({0}) to dependentAssemblies processed" -f $processed.name)
						$dependentAssemblies.Add($processed)
					} # if $dependentAssemblies.Count -eq 0
					else
					{
						if($dependentAssemblies.Contains($processed))
						{
							# This name has already been processed, so remove the node
							Write-Verbose ("Removing duplicate assemblyIdentity ({0})" -f $processed.namename)
							$_.ParentNode.RemoveChild($_)
						} # if
						else
						{
							Write-Verbose ("Add ({0}) to dependentAssemblies processed" -f $processed.name)
							$dependentAssemblies.Add($processed)
						} # else
					} # else
				} # ForEach-Object
	} # try
	catch
	{
		Write-Warning ("Catch scriptblock : ({0})" -f $Error[0].Exception)
	} # catch
	finally
	{
		Write-Verbose ("Finally scriptblock")
	} # finally
} # process