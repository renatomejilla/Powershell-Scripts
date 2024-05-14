param ($csvPath)
$Date = Get-Date -format MMM-dd-yyyy
$narr = @()

#$csvPath = 'C:\temp\APPDATA_DFSPath.csv'

$DFSPaths = Import-Csv $csvPath

Function Get-NTFSPermissions {
    param($FolderPath)

    Write-Host "Getting NTFS permissions for $Folderpath..."

        try {

            $ninfo = (Get-Acl $FolderPath -ErrorVariable nError -ErrorAction SilentlyContinue).Access
                
            foreach ($n in $ninfo) {

                New-Object psobject -Property @{
                    DFSPath = $FolderPath;
                    AccountName = $n.IdentityReference;
                    FileSystemRights = $n.FileSystemRights;
                    AccessControlType = $n.AccessControlType;
                    PermissionInherited = $n.IsInherited;
                    Comment = $comment
                } | Select DFSPath,AccountName,FileSystemRights,AccessControlType,PermissionInherited,Comment `
                  | Export-Csv "c:\temp\APPDATA_NTFS_$Date.csv" -NoTypeInformation -Append
                                                    
            }

        }

        catch {

            New-Object psobject -Property @{
                DFSPath = $FolderPath;
                AccountName = "";
                FileSystemRights = "";
                AccessControlType = "";
                PermissionInherited = "";
                Comment = $nerror
            } | Select DFSPath,AccountName,FileSystemRights,AccessControlType,PermissionInherited,Comment `
              | Export-Csv "c:\temp\APPDATA_NTFS_$Date.csv" -NoTypeInformation -Append

        }

}


Foreach ($Path in $DFSPaths) {
    
    
    Get-NTFSPermissions -FolderPath $Path.DFSLink
    

    $subfolders = Get-ChildItem $Path.DFSLink -ErrorVariable AccessError -ErrorAction SilentlyContinue -Directory



    if (!($AccessError.Count)) {

        foreach ($subfolder in $subfolders) {

            Get-NTFSPermissions -FolderPath $subfolder.FullName

            Write-Host "Getting last modified date on $($subfolder.FullName) ..."

            #$subfolder | Select @{Name='DFSPath'; Expression = {$_.FullName}}, LastWriteTime
            $subfolder | Select @{Name='DFSPath'; Expression = {$_.FullName}}, LastWriteTime | Export-Csv "c:\temp\APPDATA_LastAccessed_$Date.csv" -Append -NoTypeInformation

        }

    }

    else {

        New-Object psobject -Property @{DFSPath=$Path.DFSLink; LastWriteTime='"' + $AccessError + '"'} | Export-Csv "c:\temp\APPDATA_LastAccessed_$Date.csv" -Append -NoTypeInformation
    
    }

}
     
