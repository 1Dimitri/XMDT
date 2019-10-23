param(
    
    [string]$SourceRootFolder ,
    [Parameter(Mandatory = $true)]
    [string]$TargetRootFolder

)

Write-Verbose "Starting $($MyInvocation.MyCommand.Path)"
if ([String]::IsNullOrEmpty($SourceRootFolder)) {
    $SourceRoot = $PSScriptRoot
}
else {
    $SourceRoot = $SourceRootFolder
}

Write-Verbose "Searching for Additional files  $($SourceRoot)"

$patch_extension = '.diff'


Get-ChildItem -Path $SourceRoot  -recurse | Where-Object { $_.DirectoryName -ne $SourceRoot } | Where-Object { $_.Extension -ne $patch_extension } | ForEach-Object {
     
    If (!$_.PSIsContainer) {
        $filename_fullname = $_.FullName
        Write-Verbose "Handling $filename_fullname"
        $target_relative_filename = $filename_fullname.Substring($SourceRoot.Length)
     
        $target_filename = Join-Path $TargetRootFolder $target_relative_filename
        Write-Verbose "Testing the existence of $($target_filename)"
        if (Test-Path $target_filename ) {
            Write-Verbose "Already exists: $target_filename"
        
        
        }
        else {
            Write-Verbose "Copying $filename_fullname to $target_filename"
            Copy-Item -Path $filename_fullname -Destination $target_filename -Force

        }
    }

}