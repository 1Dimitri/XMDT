param(
    
    [Parameter(Mandatory=$true)]
    [string]$SourceRootFolder,  # $PSScriptRoot?
    [Parameter(Mandatory=$true)]
    [string]$TargetRootFolder,
    [string]$patchcmd='..\diff\patch.exe'
)

Get-ChildItem -Path $SourceRootFolder  -recurse | Where-Object { $_.Extension -eq '.diff' } | ForEach-Object {
     $patch_fullname = $_.FullName
     Write-Verbose "Using patch $patch_fullname"
     $patch_extension = $_.Extension   # '.xx.yy -> .yy'
     $patch_basename=$_.BaseName  # '.xx.yy -> .xx'
     $directory_relative_name = $_.FullName.Substring($SourceRootFolder.Length)
     Write-Verbose "$directory_relative_name"
     $target_filename_with_ext = Join-Path $TargetRootFolder $directory_relative_name

     $target_filename = $target_filename_with_ext.SubString(0,$target_filename_with_ext.length-$patch_extension.Length)
     if (Test-Path $target_filename ) {
        Write-Verbose "Patching $target_filename with $patch_fullname"
        # TO DO: Define patch command
        &$patchcmd  "$target_filename" "$patch_fullname" -o "$target_filename"

     }
}