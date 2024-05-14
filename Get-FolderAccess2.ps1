param ($DFSPath)
$Date = Get-Date -format MMM-dd-yyyy
$narr = @()

#$csvPath = 'C:\temp\APPDATA_DFSPath.csv'

#$DFSPaths = Import-Csv $csvPath

$name = $DFSPath.Split("\")[$DFSPath.Split("\").Count -1]
$output_permissions = "c:\temp\$name" + "_Permissions_" + "$Date" + ".csv"
$output_lastaccess = "c:\temp\$name" + "_LastAccess_" + "$Date" + ".csv"


Function Get-Supervisor{
    Param ($ADObject)

    Write-Host "Getting information for $ADObject"
    $Filter = 'CN -eq ' + '"' + $ADObject + '"' + ' -or SamAccountName -eq ' + '"' + $ADObject + '"'

    $obj = Get-ADObject -Filter $Filter -SearchBase 'DC=PMINTL,DC=NET' -Server PMICHLAUGC34

    if ($obj.ObjectClass -eq "group") {
        $s = (Get-ADGroup -Identity $obj.DistinguishedName -Properties ManagedBy -Server PMICHLAUGC34).ManagedBy
    }

    if ($obj.ObjectClass -eq "user") {
        $s = (Get-ADUser -Identity $obj.DistinguishedName -Properties Manager -Server PMICHLAUGC34).Manager
    }

    If ($s -ne $Null) {
        $Supervisor = (Get-ADUser $s).Name
    }

    return $Supervisor
}

Function Get-NTFSPermissions {
    param($FolderPath)

    Write-Host "Getting NTFS permissions for $Folderpath..."

        try {
            
            $ninfo = (Get-Acl $FolderPath -ErrorVariable nError -ErrorAction SilentlyContinue).Access
                
            foreach ($n in $ninfo) {

                if ($n.IdentityReference.Value.StartsWith("PMI\")) {
                    $s = Get-Supervisor -ADObject $n.IdentityReference.Value.Replace("PMI\","")
                }

                New-Object psobject -Property @{
                    DFSPath = $FolderPath;
                    AccountName = $n.IdentityReference;
                    FileSystemRights = $n.FileSystemRights;
                    AccessControlType = $n.AccessControlType;
                    Supervisor = $s
                    Comment = $comment
                } | Select DFSPath,AccountName,FileSystemRights,AccessControlType,Supervisor,Comment `
                  | Export-Csv $output_permissions -NoTypeInformation -Append
                                                    
            }

        }

        catch {
            
            New-Object psobject -Property @{
                DFSPath = $FolderPath;
                AccountName = "";
                FileSystemRights = "";
                AccessControlType = "";
                Supervisor = $s
                Comment = $nerror
            } | Select DFSPath,AccountName,FileSystemRights,AccessControlType,Supervisor,Comment `
              | Export-Csv $output_permissions -NoTypeInformation -Append

        }

}


Get-NTFSPermissions -FolderPath $DFSPath
    

$subfolders = Get-ChildItem $DFSPath -ErrorVariable AccessError -ErrorAction SilentlyContinue -Directory



if (!($AccessError.Count)) {

    foreach ($subfolder in $subfolders) {

        Get-NTFSPermissions -FolderPath $subfolder.FullName 

        Write-Host "Getting last modified date on $($subfolder.FullName) ..."

        #$subfolder | Select @{Name='DFSPath'; Expression = {$_.FullName}}, LastWriteTime
        $subfolder | Select @{Name='DFSPath'; Expression = {$_.FullName}}, LastWriteTime | Export-Csv $output_lastaccess -Append -NoTypeInformation

    }

}

else {

    New-Object psobject -Property @{DFSPath=$DFSPath; LastWriteTime='"' + $AccessError + '"'} | Export-Csv $output_lastaccess -Append -NoTypeInformation
    
}
     
