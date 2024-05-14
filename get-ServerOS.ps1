param ($SFile, $OFile)

$SRVs = get-content $SFile

$a = @()

foreach ($srv in $SRVs) {

    try {
        Write-Host "Checking $srv"
        $tmp = get-adcomputer $srv -Properties * | Select Name,OperatingSystem,LastLogonDate,Created
        $a += New-Object PSObject -Property @{MachineName = $tmp.name; OperatingSystem = $tmp.OperatingSystem; LastLogonDate = $tmp.LastLogonDate; DateCreated=$tmp.Created; Comment=""}
    }
    catch {
        $a += New-Object PSObject -Property @{MachineName = $srv; OperatingSystem = ""; LastLogonDate = ""; DateCreated=""; Comment = "Not found in AD"}
    }
}

$a | Export-Csv -Path $OFile -force -NoTypeInformation