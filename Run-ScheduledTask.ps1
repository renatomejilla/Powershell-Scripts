$Servers = import-csv C:\Temp\ActiveDFSServers_30-Sep-2019.csv
$ScriptName = "Get-UserHomeFolder"
foreach ($a in $Servers) {
	$tmp =  $a.dfspath.split("\")[$a.dfspath.split("\").count - 1]
	Get-ScheduledTask -TaskName "$ScriptName {$tmp}" -CimSession $a.ServerName | Start-ScheduledTask
}