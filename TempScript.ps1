Import-Module C:\temp\Get-ServerShare\AlphaFS.2.2.6.0\Lib\Net35\AlphaFS.dll

$SFs = Import-Csv C:\temp\Get-ServerShare\SFS.TXT
$ServerName = $env:COMPUTERNAME

$SharedFolders = @()

$Shares = $SFs | ? {$_.ServerName -eq $ServerName}

Foreach ($Share in $Shares) {

    $ErrorMessage=$Null

    Write-Host "Getting the size of $($Share.TargetPath) ..."

    try {
        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Recursive -bor `
            [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::FilesAndFolders
        $pathFormat = [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath
        $properties = [Alphaleonis.Win32.Filesystem.Directory]::GetProperties($Share.TargetPath, $dirEnumOptions, $pathFormat)
        $Size = "{0:N2}" -f ($properties.Size/1MB)
    }

    catch {
        $ErrorMessage = "Not able to get the total size of $Share : " + $Error[0]
        #Save-ToLog -Message $ErrorMessage -LogFile $ErrorLogFile

        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Recursive -bor `
            [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::ContinueOnException -bor `
            [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::FilesAndFolders
        $pathFormat = [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath
        $properties = [Alphaleonis.Win32.Filesystem.Directory]::GetProperties($Share.TargetPath, $dirEnumOptions, $pathFormat)
        $Size = "{0:N2}" -f ($properties.Size/1MB)
    } 

    $SharedFolders += New-Object psobject -Property @{SharedPath=$Share.TargetPath; 'Size (MB)'=$Size; Comment=$ErrorMessage}
}    
  
    $SharedFolders |Select SharedPath,'Size (MB)', Comment| Export-Csv C:\temp\DfsSF_Size.csv -NoTypeInformation


Write-Host "Done!"