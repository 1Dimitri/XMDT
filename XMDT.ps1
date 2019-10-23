
$dirHelpers = Join-Path $PSScriptRoot 'Helpers'
$dirTemplates = Join-Path $PSScriptRoot 'Templates'

# Implementation choice:
# Not implementing a module because 
# 1. exporting and importing classes in PS is still not widely supported and known by People
# 2. BDD is still a PSSnapIn


. (Join-Path $dirHelpers 'MDTHelpers.ps1')


Remove-Item -Path 'C:\XMDT002' -Force -EA SilentlyContinue -Recurse
$x = New-XMDTShare C:\XMDT002
$patchps1 = Join-Path $dirTemplates 'Apply-Patches.ps1'
$addfilesps1 = Join-Path $dirTemplates 'Add-Additional-Files.ps1'

$x.RunScriptOnHierarchy($patchps1)
$x.RunScriptOnHierarchy($addfilesps1)