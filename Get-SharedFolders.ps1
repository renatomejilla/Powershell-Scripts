$CTMs = Get-Content C:\temp\CTMs.txt


foreach ($CTM in $CTMs) {

    $Shares = Get-SmbShare -CimSession $CTM | ? {($_.Path -match '^\w{1}:') `
        -And ($_.Path -notmatch 'C:\\DFSRoots') `
        -And ($_.Path -notmatch 'C:\\Windows') `
        -And ($_.Name -notmatch '^\w{1}\$') `
        -And ($_.Description -notmatch 'Printer Drivers')
    } | Select Name, Path, Description


    foreach ($Share in $Shares) {
        Get-SmbShareAccess -Name $Share.Name -CimSession $CTM | Export-Csv c:\temp\CTMs_SMB.csv -Append
        "\\$CTM\$($Share.Name)"
        (Get-Acl "\\$CTM\$($Share.Name)").Access  | Select @{Name="ServerName";E={$CTM}}, @{Name="SharedFolderPath";E={"\\$CTM\$($Share.Name)"}},`
            @{Name="LocalPath";E={($Share.Path)}},FileSystemRights,AccessControlType,IdentityReference,IsInherited,InheritanceFlags,PropagationFlags `
            | Export-Csv c:\temp\CTMs_NTFS.csv -Append
    }
}