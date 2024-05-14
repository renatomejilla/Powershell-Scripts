$srv = $env:ComputerName
$tarr = @()
$Date = Get-Date -format MMM-dd-yyyy

<#As per agreement, we can exclude default shared folders e.g. the root folder drive.
The list below can be updated to exclude technical drives
#>

$Shares = Get-SmbShare | ? {($_.Path -match '^\w{1}:') `
                    -And ($_.Path -notmatch 'DFSRoots') `
                    -And ($_.Name -notmatch '^\w{1}\$') `
                    -And ($_.Description -notmatch 'Remote Admin') `
                    -And ($_.Description -notmatch 'Printer Drivers')
                 } | Select Name, Path, Description


foreach ($Share in $Shares) {

    $sPath = "\\$srv\$($Share.Name)"
    Write-Host "Getting Share Permission for $sPath"
    $sInfo = Get-SmbShareAccess $Share.Name

    foreach ($s in $sInfo) {

        if (($s.AccountName -match 'Authenticated Users') -Or `
            ($s.AccountName -match 'Everyone') -Or `
            ($s.AccountName -match 'Domain Users')) {
                
            $Comment = "Review Permission"
            
        }
        else {
            $Comment = ""
        }

        $tarr += New-Object psobject -Property @{
                    SharedFolderPath = $sPath;
                    AccountName = $s.AccountName;
                    AccessControlType = $s.AccessControlType;
                    AccessRight = $s.AccessRight;
                    Comment = $Comment
                }
    }
}

$filename = $srv + "_SharedFolderPermissions_" + $Date + ".csv"
$tarr | Select SharedFolderPath,AccountName,AccessControlType,AccessRight, Comment `
    | Export-Csv $filename -NoTypeInformation