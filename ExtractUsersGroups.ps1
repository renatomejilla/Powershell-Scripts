$dfsNamespacePath = @(
	"\\PMINTL.NET\APPDATA\PMI-ITSC-GSVC-QAS\OVF-GSVC"
)

$outputCsvPath = "C:\DFS_UsersGroups.csv"

function Get-DFSPermissions {
    param (
        [string]$DFSPath
    )

    $acl = Get-Acl -Path $DFSPath

    foreach ($access in $acl.Access) {
        
        if ($access.IdentityReference.Value.StartsWith("NT AUTHORITY\Users") -or 
            $access.IdentityReference.Value.StartsWith("BUILTIN\Users")) {
            continue
        } else {
            [PSCustomObject]@{
                "DFS_Path" = $DFSPath
                "User/Group" = $access.IdentityReference
                "Permissions" = $access.FileSystemRights
            }
        }
    }
}

$permissions = @()

$dfsFolders = Get-ChildItem -Path $dfsNamespacePath -Directory

foreach ($folder in $dfsFolders) {
        $permissions += Get-DFSPermissions -DFSPath $folder.FullName
}

$permissions | Export-Csv -Path $outputCsvPath -NoTypeInformation
