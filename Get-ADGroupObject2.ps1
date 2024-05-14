[cmdletbinding()]
param(
    [parameter(
        Mandatory         = $false,
        ValueFromPipeline = $true)]
    $inputpipe,
    $CSVPath
)

Process {

    if ($inputpipe -eq $Null) {
        $inputpipe = Import-Csv $CSVPath
    }
    $inputpipe | % {

        #$Filter = "'" + 'CN -eq ' + '"' + $_.ADObject + '"' + "'"

        Write-Host "Getting information for $($_.ADObject)"
        $Filter = 'CN -eq ' + '"' + $_.ADObject + '"' + ' -or SamAccountName -eq ' + '"' + $_.ADObject + '"'

        $obj = Get-ADObject -Filter $Filter -SearchBase 'DC=PMINTL,DC=NET' -Server PMICHLAUGC34

        if ($obj.ObjectClass -eq "group") {
            $i = Get-ADGroup -Identity $obj.DistinguishedName -Properties ManagedBy -Server PMICHLAUGC34
            try {
                $m = (Get-ADUser $i.ManagedBy -Server PMICHLAUGC34).Name
            }
            catch {
                $m =""
            }

            $i.Name
            New-Object psobject -Property @{
                Name = $i.Name;
                SamAccountName = $i.SamAccountName;
                'Supervisor/Owner' = $m
            } | Export-Csv "C:\Temp\SharedFolderUsers1.Csv" -NoTypeInformation -Append
        }

        if ($obj.ObjectClass -eq "user") {
            $i = Get-ADUser -Identity $obj.DistinguishedName -Properties Manager -Server PMICHLAUGC34
            try {
                $m = (Get-ADUser $i.Manager -Server PMICHLAUGC34).Name 
            }
            catch {
                $m = ""
            }

            $i.Name
            New-Object psobject -Property @{
                Name = $i.Name;
                SamAccountName = $i.SamAccountName;
                'Supervisor/Owner' = $m
            } | Export-Csv "C:\Temp\SharedFolderUsers1.Csv" -NoTypeInformation -Append
        }
    }
}