$dfsrs = Get-DfsReplicatedFolder
$dfsrinfo = @()
$Date = Get-Date -Format MMM-dd-yyyy
$filename = "C:\Temp\DFSR-Info_$Date.csv"

foreach ($dfsr in $dfsrs) {
    
    Write-Host "Retrieving information for $($dfsr.FolderName)..."
    $dfsrmembers = $dfsr | Get-DfsrMembership

    foreach($dfsrmember in $dfsrmembers) {

        $dfsrinfo = New-Object psobject -Property @{
                        ReplicatedFolderGroupName = $dfsrmember.GroupName
                        FolderName = $dfsrmember.FolderName;
                        DFSPath = $dfsr.DfsnPath;
                        TargetSharedFolder = $dfsrmember.DfsnPath;
                        ContentPath = $dfsrmember.ContentPath;
                        ComputerName=$dfsrmember.ComputerName
                    }

        $dfsrinfo | Select FolderName, DFSPath, TargetSharedFolder, ContentPath, ComputerName `
                    | Export-Csv C:\Temp\DFSR_Info.csv -NoTypeInformation -Append
    }
}

Write-Host "Done!"