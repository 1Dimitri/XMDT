<#
.SYNOPSIS
    Get contents of INI files
.DESCRIPTION
    Returns the contents of a ini file as a hashtable
    Allows to expand strings section in a INF File
.EXAMPLE
    Get-IniContents -Path 'C:\temp\driver.inf' -ExpandStrings
.EXAMPLE
    Get-InitContents -PAth 'C:\Windows\System32\appraiser\AppRaiser_Data.ini'
.INPUTS
    Path: Path to the filename
    FileInfo: System.IO.FileInfo object as returned by Get-ChildItem, etc.
    ExpandStrings: replace %variable% with their contents in the section Strings if any (INF driver basic support)
.OUTPUTS
    2-level hashtable e.g.
    Write-Host "Manufacturer is $((Get-IniContents -Path 'C:\temp\driver.inf' -ExpandStrings).Version.Provider)"
#>

function Get-IniContents {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            Position = 0,
            ParameterSetName = "Filename",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to location.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            Position = 0,
            ParameterSetName = "Fileinfo",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "FileInfo Object.")]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]
        $FileInfo,
        # Parameter help description
        # [Parameter()]
        [Switch]
        $ExpandStrings
    )    

    switch ($PsCmdlet.ParameterSetName) {
        "Filename" {
            $filename = $Path
        }
        "FileInfo" {
            $filename = $FileInfo.FullName
        }
        # "__AllParameterSets" { 
        # }
    }

    $ini = @{ }
    $section = "_sectionless_"
    $ini[$section] = @{ }

      
    switch -regex -file $filename {
        "^\[(.+)\]$" {
            $section = $matches[1].Trim()
            $ini[$section] = @{ }
        }
        "^\s*([^#].+?)\s*=\s*(.*)" {
            $name, $value = $matches[1..2]
            # skip comments that start with semicolon:
            if (!($name.StartsWith(";"))) {
                $ini[$section][$name] = $value.Trim()
            }
        }
    }

    if ($ExpandStrings -and $ini['Strings']) {

        $replacefn = {
            param($match)        
                        
                        if ($ini['Strings'].ContainsKey($match.Groups[1].Value)) {
                            $ini['Strings'][$match.Groups[1].Value]
                               
                        } else {
                            '%'+$match.Groups[1].Value+'%'
                        }

        }

        foreach ($sectionkey in $ini.Keys) {
            $sectionhash = $ini[$sectionkey]
            
            @($sectionhash.GetEnumerator()) | ForEach-Object {
                $key = $_.key
                $sectionvalue = $_.Value
                $result=  [regex]::Replace($sectionvalue, '%([^%]+?)%', $replacefn)
                if ($result -ne $sectionvalue)
                {
                 $ini[$sectionkey][$key]=$result
                }
                #     # from: https://stackoverflow.com/questions/30666101/use-a-function-in-powershell-replace  for PS 5.1
                }
            }

    
    }

    $ini
}