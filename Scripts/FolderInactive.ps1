$sharedPath = Read-Host -Prompt "Please enter the shared folder path (e.g., \\your\shared\server\path): "

$inactiveDays = 30  

function Check-Inactivity {
    param (
        [string]$path,
        [int]$days
    )
    $currentDate = Get-Date
    $cutoffDate = $currentDate.AddDays(-$days)

    $items = Get-ChildItem -Path $path -Recurse

    foreach ($item in $items) {
        $lastAccessTime = [System.IO.File]::GetLastAccessTime($item.FullName)

        if ($lastAccessTime -lt $cutoffDate) {
            [PSCustomObject]@{
                Path            = $item.FullName
                LastAccessTime  = $lastAccessTime
                Type            = if ($item.PSIsContainer) { "Folder" } else { "File" }
            }
        }
    }
}

if (Test-Path -Path $sharedPath) {
    $inactiveItems = Check-Inactivity -path $sharedPath -days $inactiveDays
    $inactiveItems | Export-Csv -Path "InactiveFilesAndFolders.csv" -NoTypeInformation

    Write-Output "Inactive files and folders have been exported to InactiveFilesAndFolders.csv"
} else {
    Write-Output "The specified path does not exist. Please check the path and try again."
}


