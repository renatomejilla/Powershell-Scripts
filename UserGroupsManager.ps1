# Author: Renato D. Mejilla
# Date: May 14, 2024
# Description: To extract who is managing the user groups in AD.

# Import the Active Directory module
Import-Module ActiveDirectory

# Function to get group managers
function Get-ADGroupManagers {
    # Retrieve all AD groups
    $groups = Get-ADGroup -Filter * -Property ManagedBy

    # Initialize an array to store results
    $results = @()

    foreach ($group in $groups) {
        # Get the group's ManagedBy attribute
        $managerDN = $group.ManagedBy

        if ($managerDN) {
            # Get the manager's details
            $manager = Get-ADUser -Identity $managerDN

            # Add the group and manager details to the results array
            $results += [PSCustomObject]@{
                GroupName = $group.Name
                GroupDistinguishedName = $group.DistinguishedName
                ManagerName = $manager.Name
                ManagerDistinguishedName = $manager.DistinguishedName
                ManagerEmail = $manager.EmailAddress
            }
        }
    }

    # Return the results
    return $results
}

# Execute the function and store the results
$groupManagers = Get-ADGroupManagers

# Output the results to the console
$groupManagers | Format-Table -AutoSize

# Optionally, export the results to a CSV file
$groupManagers | Export-Csv -Path "ADGroupManagers.csv" -NoTypeInformation
