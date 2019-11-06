Add-PSSnapin Microsoft.BDD.PSSnapin

# Encapsulates an MDT Drive as an object with methods
class XMDTPSDrive {
     
    [System.Management.Automation.PSDriveInfo] $_drive

    XMDTPSDrive([System.Management.Automation.PSDriveInfo] $Drive) {
        $this._drive = $Drive 
    }

    

    # Add an OS to the drive
    AddOS([string] $Path) {


        $MDTOSFolder = FindFolderTypeFirst('OperatingSystemFolder')
        $FolderMode = $true  #TODO:WIM mode

        $DestinationFolder = Split-Path $Path -Leaf #TODO: Better algorithm taking install.wim into account

        if ($FolderMode) {
            Import-MDTOperatingSystem -SourcePath $Path -DestinationFolder $DestinationFolder -Path $MDTOSFolder
        }
    }

    
    # Add a driver from path to the drive
    [void] AddDriver([string] $Path) {


        $MDTDriverFolder = FindFolderTypeFirst('DriverFolder')
        $FolderMode = $true  #TODO:CAB mode

        $DestinationFolder = Split-Path $Path -Leaf #TODO: Better algorithm taking inf contents into account

        if ($FolderMode) {
            Import-MDTDriver -SourcePath $Path -DestinationFolder $DestinationFolder -Path $MDTDriverFolder
        }
    }

    # Returns the first specialized folder of a given type
    FindFolderTypeFirst([string]$FolderType) {
        
        Get-ChildItem -Path "$($this._drive):" | Where-Object { $_.NodeType -eq $FolderType } | Select-Object -First 1
    }

    [void] RunScriptOnHierarchy([string] $Path) {
        if (Test-Path $path) {
            Write-Verbose "Running $path command"
             & $path -TargetRootFolder $this._drive.Root
        } 
    }
}

function New-DirectoryIfNotExists {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String]
        $Directory
    )
    
    If (!(Test-Path -Path $Directory)) {
        New-Item -Path $Directory -Type Directory
    }
}
        
function New-SmbShareIfNotExists {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String]
        $Directory,
        [Parameter(Position = 1)]
        [String]
        $ShareName
    )

    if (!$ShareName) {
        $ShareName = Split-Path $Directory -Leaf
    }
    $shareObj = Get-SmbShare $ShareName -ErrorAction SilentlyContinue
    if ($ShareObj) {
        if ($shareObj.Path -ne $Directory) {
            Remove-SmbShare -Name $ShareName                    
            New-DirectoryIfNotExists $Directory
            $shareObj = New-SmbShare -Name $ShareName -Path $Directory  #TODO: SecurityDescriptor    
        }
    }
    else {
        New-DirectoryIfNotExists $Directory
        $shareObj = New-SmbShare -Name $ShareName -Path $Directory  #TODO: SecurityDescriptor        
    }
}

function New-XMDTShare {
    param (
        [string] $Directory
    )
    
    New-SmbShareIfNotExists -Directory $Directory
    
    $NextAvailableIndex = 0
    $TryMDTDriveName = ''

    do {
        $NextAvailableIndex += 1
        $TryMDTDriveName = "XMDT{0:000}" -f $NextAvailableIndex

    } until ($null -eq (Get-PSDrive -LiteralName $TryMDTDriveName -ErrorAction SilentlyContinue))

    $MDTPSDrive = New-PSDrive -Name $TryMDTDriveName -PSProvider 'MDTProvider' -Root $Directory

    [XMDTPSDrive]::new($MDTPSDrive)

}


