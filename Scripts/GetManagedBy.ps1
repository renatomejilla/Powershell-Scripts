# Author: Renato Mejilla
# Date: July 4, 2024
# Description: To extract who is managing the users/groups in AD

Import-Module ActiveDirectory

function Get-ManagedBy {
    param (
        [string]$Name
    )

    try {
        $adObject = Get-ADObject -Filter { Name -eq $Name } -Property ManagedBy
        if ($adObject) {
            return $adObject.ManagedBy
        } else {
            return "No such user or group found in Active Directory."
        }
    } catch {
        return "An error occurred: $_"
    }
}

while ($true) {
    $inputName = Read-Host "Enter the user or group name (or type 'exit' to quit)"
    if ($inputName -eq 'exit') {
        break
    }

    $managedBy = Get-ManagedBy -Name $inputName
    Write-Host "Managed By for ${inputName}: $managedBy"
}
