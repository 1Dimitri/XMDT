# Create diff patch utilities



Add-Type -Path (Join-Path $PSScriptRoot 'diff_match_patch.cs')


function New-PatchData  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $SourceFile,
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $ComparedFile

    )
    $dmp = [DiffMatchPatch.diff_match_patch]::new()
    $srcContents = Get-Content $SourceFile -Raw
    $cmpContents = Get-Content $ComparedFile -Raw
    $patches = $dmp.patch_make([string] $srcContents,[string] $cmpContents)
    $dmp.patch_toText($patches)
}

function Save-PatchData  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $SourceFile,
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $ComparedFile,
        [Parameter(Mandatory=$true,Position=2)]
        [string]
        $OutputFile


    )
    $dmp = [DiffMatchPatch.diff_match_patch]::new()
    $srcContents = ((Get-Content $SourceFile) -join "`n") + "`n"
    $cmpContents = ((Get-Content $ComparedFile) -join "`n") + "`n"
    $patches = $dmp.patch_make([string] $srcContents,[string] $cmpContents)
    # patch_toText generates LF separated string, and adding a new line will confuse patch_fromText
    $dmp.patch_toText($patches) | Set-Content -Path $OutputFile -NoNewline


}


function Get-PatchData  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $PatchFile
    )
    $dmp = [DiffMatchPatch.diff_match_patch]::new()
    $srcContents = Get-Content $PatchFile -Raw
    $dmp.patch_fromText($srcContents)
}


function Convert-UsingPatchData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $SourceFile,
        [Parameter(Mandatory=$true,Position=1)]
        $PatchData,
        [Parameter(Mandatory=$true,Position=2)]
        [string]
        $outputFile
    )

    $dmp = [DiffMatchPatch.diff_match_patch]::new()
    $patches = Get-PatchData $PatchData
    $srcContents = Get-Content $SourceFile -Raw
    $result = $dmp.patch_apply($patches,$srcContents)
    Set-Content -Value $result[0] -Path $outputFile -Force

}



function New-FileFromBase {

        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true,Position=0)]
            [string]
            $SourceFile,
            [Parameter(Mandatory=$true,Position=1)]
            [string]
            $ComparedFile,
            [Parameter(Mandatory=$true,Position=2)]
            [string]
            $outputFile
            
        )
        $dmp = [DiffMatchPatch.diff_match_patch]::new()
        $srcContents = Get-Content $SourceFile -Raw
        $cmpContents = Get-Content $ComparedFile -Raw
        $patches = $dmp.patch_make([string] $srcContents,[string] $cmpContents)
        $result = $dmp.patch_apply($patches,$srcContents)
 
        Set-Content -Value $result[0] -Path $outputFile -Force
        
}

