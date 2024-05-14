$Date = Get-Date
Tee-Object -InputObject "Script started on $Date" -FilePath "C:\temp\Query.log" -Append

$Servers = Import-Csv "E:\PMI-DeptDrive-Migration-Report\Source\DepartmentFolders.csv" | `
     Select ServerName -Unique | % {$_.ServerName}

#$Servers = Import-Csv "C:\Temp\DepartmentFolders.csv" | `
#     Select ServerName -Unique | Sort-Object-| % {$_.ServerName}

$Exclusions = "ADMIN$","APPDATA","automation","C$","D$","E$","F$","G$","H$","I$","J$", `
    "K$","L$","M$","N$","O$","P$","Q$","R$","S$","T$","U$","V$","W$","X$","Y$","Z$", `
    "DEPTDATA","IPC$","print$","USERDATA", "RBSDATA","EARCHIVE","HMSDATA","REMINST", `
    "SCCMContentLib$","SMS_DP$"

$SharedFolders = @()


foreach ($srv in $Servers) {

    try {
        Tee-Object -InputObject "Remotely checking shared servers on $srv" -FilePath "C:\temp\Query.log" -Append
        $Shares = Invoke-Command -ComputerName $srv {Get-smbshare | Select Name, Path}

        foreach ($shr in $Shares) {
            if ($Exclusions -contains $shr.Name) {
                Continue
            }
            else {
                $SharedFolders += New-Object psobject -Property @{SharedFolderName=$shr.Name; Path=$shr.Path; Server=$srv}
            }
        }
    }
    catch {
        Tee-Object -InputObject "Error connecting to $srv" -FilePath "C:\temp\Query.log" -Append
    }
}

$SharedFolders | Select SharedFolderName, Path, Server | Export-Csv -Path "C:\Temp\SharedFolders.csv" -NoTypeInformation

Tee-Object -InputObject "Script terminated on $Date" -FilePath "C:\temp\Query.log" -Append

            

            