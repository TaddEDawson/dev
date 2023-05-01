<#
    .SYNOPSIS
        Identify duplicate entries in web.config file
#>
[CmdletBinding()]
param
(
    $ConfigFile = ".\web.config"
) # param
process
{
    $ErrorActionPreference = "Stop"
    try
    {
        Write-Verbose ("Try")
        [Xml] $ConfigXML = Get-Content $ConfigFile
        $ConfigXml
    } # try
    catch
    {
        Write-Warning ("Catch : ({0})" -f $Error[0])
    } # catch
    finally
    {
        Write-Verbose ("Finally")
    } # finally
} # process