#Examples:
#Folder:
#.\Get-AccessRightsInfo.ps1 -Path E:\PMI-DeptDrive-Migration-Report\Reports -SaveToCsvFile c:\temp\test.csv
#File:
#.\Get-AccessRightsInfo.ps1 -Path C:\temp\test1.txt -SaveToCsvFile C:\Temp\test.csv

param ($Path, $SaveToCsvFile)

$info = Get-Acl -Path $Path
$ACL = @()
$Machine=$env:COMPUTERNAME

foreach ($object in $info.Access) {
    $ACL += New-Object psobject -Property @{
        ServerName=$Machine
        Path = $Path
        Owner = $info.Owner
        "User/Group" = $object.IdentityReference
        AccessControlType = $object.AccessControlType
        FileSystemRights = $object.FileSystemRights
    }
}

$ACL | Select ServerName,Path,Owner,"User/Group",AccessControlType,FileSystemRights | Export-Csv $SaveToCsvFile -NoTypeInformation


