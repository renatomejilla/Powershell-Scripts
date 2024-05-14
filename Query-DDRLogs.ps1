$Directory = "E:\PMI-DeptDrive-Migration-Report\Logs\2022-03-23"
$files = Get-ChildItem $Directory  |  % {$_.Name}

$arr = @()

foreach ($file in $files) {
    Write-Host "Checking $file"
    $servername = $files.split("_")[0]

    $Content = Get-Content "$Directory\$file"

    foreach ($line in $Content) {
        if ($line -eq "") {
            Continue
        }

        if ($line -match "Not able to get the total size of") {
            $t = $line.SubString(56)
            $fi = $t.IndexOf("Exception")
            $m = $t.Substring(0,$t.IndexOf(" : Exception"))
            $fi = $m.IndexOf(" on ")
            $tmpD = $t.SubString(0,$fi)
            $msg = $t
            #$f = ($t.SubString($li)).Split(" ")[0]
            #Write-Host "$tmpD, $msg"
            
        }
        else {
            $t = $line.SubString(22)
            $li = $t.IndexOf(" does not")
            $tmpD = $t.SubString(0,$li)
            $msg = $t
            #$f = ($t.SubString($li)).Split(" ")[0]
            #Write-Host "$tmpD"
        }
        $arr += New-Object psobject -Property @{
            ServerName = $servername
            Directory = $tmpD
            Comment = $msg
        }
    }
}