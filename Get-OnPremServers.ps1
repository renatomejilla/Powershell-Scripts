$Date=Get-Date -Format MMM-dd-yyy
Get-ADComputer -properties OperatingSystem,CanonicalName -Filter `
    '(OperatingSystem -like "Windows Server*")' | ? {($_.CanonicalName -NotMatch "INT-SDI") -And ($_.CanonicalName -NotMatch "INT-Cloud")} `
    | Select Name,CanonicalName,OperatingSystem | Export-Csv "C:\Temp\WinServers_$Date.csv" -NoTypeInformation

