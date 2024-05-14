#$global:DFSShares = Import-Csv C:\temp\DFSSHares.csv
$NameSpaces = "\\pmintl.net\USERDATA", "\\pmintl.net\HMSDATA", "\\pmintl.net\EARCHIVE", "\\pmintl.net\DEPTDATA", "\\pmintl.net\APPDATA"
$Date = Get-Date -Format MMM-dd-yyyy
$global:DFSShares = @();

Foreach ($NameSpace in $NameSpaces) {
    Write-Host "Querying $NameSpace"
    $t = (Get-ChildItem $NameSpace)

    foreach ($i in $t) {
        $global:DFSShares += New-Object PSObject -Property @{Path = $i.FullName}
    }
}

$global:DFSlinks = @()


function Collect-DfsLinks {
    param ($DFSLink)

    Write-Host "Querying $DFSLink"
    try {
        $targets = Get-DfsnFolderTarget -Path $DFSLink -ErrorAction Stop
        foreach ($target in $targets) {
            $ServerName = $target.TargetPath.Split("\")[2]
            $global:DFSlinks += New-Object PSObject -Property @{DFSPath = $DFSLink; TargetPath = $target.TargetPath; ServerName =  $ServerName; State = $target.State; Priority=$target.ReferralPriorityClass}
        }
    }

    catch {
        $global:DFSlinks += New-Object PSObject -Property @{DFSPath = $DFSLink; TargetPath = "Does not Exist"; ServerName =  'N/A'; State = 'N/A'; Priority='N/A'}
        try {
            $SFs = Get-ChildItem $DFSLink -ErrorAction Stop
            foreach ($SF in $SFs) {
                Collect-DfsLinks -DFSLink $SF.FullName
            }
        }
        catch {
            Write-Host "$DFSLink does not exist"
            $global:DFSlinks += New-Object PSObject -Property @{DFSPath = $DFSLink; TargetPath = "Does not Exist"; ServerName =  'N/A'; State = 'N/A'; Priority='N/A'} 
        }

    }
}

foreach ($DFSShare in $DFSShares) {   
    Collect-DfsLinks -DFSLink $DFSShare.Path
}


$global:DFSlinks | Select ServerName, DFSPath, TargetPath, State, Priority | Export-Csv -Path "C:\temp\DFSPaths_$Date.csv" -NoTypeInformation