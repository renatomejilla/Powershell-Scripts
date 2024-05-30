# Author:      Renato Mejilla
# Date:        May 30, 2024
# Description: To check what OS the server is running.

$osCaption = (Get-WmiObject Win32_OperatingSystem).Caption
if ($osCaption -like "Windows Server 2016") {
    Write-Host "The server is running Windows Server 2016."
} else {
    Write-Host "The server is not running Windows Server 2016."
}
