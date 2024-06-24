$folderPath = Read-Host "Please enter the folder path: "

if (Test-Path $folderPath) {
    $folderSize = Get-ChildItem -Path $folderPath -Recurse -ErrorAction SilentlyContinue |
                  Measure-Object -Property Length -Sum

    $sizeInMB = [math]::round($folderSize.Sum / 1MB, 2)

    Write-Output "The size of the folder is $sizeInMB MB"
} else {
    Write-Output "The specified folder path does not exist. Please check the path and try again."
}
