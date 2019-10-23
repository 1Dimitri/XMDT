param(
    
    [string]$SourceRootFolder ,
    [Parameter(Mandatory=$true)]
    [string]$TargetRootFolder,
    [string]$patchcmd='..\diff\patch.exe'
)

Write-Verbose "Starting $($MyInvocation.MyCommand.Path)"
if ([String]::IsNullOrEmpty($SourceRootFolder)) {
    $SourceRoot = $PSScriptRoot
} else {
    $SourceRoot = $SourceRootFolder
}

Write-Verbose "Checking diff patches within $($SourceRoot)"

$patch_extension = '.diff'

$patchcmd =(Resolve-Path (Join-Path $SourceRoot $patchcmd)).Path

Get-ChildItem -Path $SourceRoot  -recurse  | Where-Object { $_.Extension -eq $patch_extension } | ForEach-Object {
     $patch_fullname = $_.FullName
     Write-Verbose "Handling patch $patch_fullname"
     $patch_extension = $_.Extension   # '.xx.yy -> .yy'
     $patch_basename=$_.BaseName  # '.xx.yy -> .xx'
     $patch_relative_filename = $_.FullName.Substring($SourceRoot.Length)
     $target_relative_filename = $patch_relative_filename.Substring(0,$patch_relative_filename.length-$patch_extension.Length)
     $target_filename = Join-Path $TargetRootFolder $target_relative_filename
     Write-Verbose "Testing the existence of $($target_filename)"
     if (Test-Path $target_filename ) {
        Write-Verbose "Patching $target_filename with $patch_fullname"
        # TO DO: Define patch command
        & $patchcmd  $target_filename $patch_fullname
     }

}