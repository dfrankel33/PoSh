
$servers = @()

foreach ($server in $servers) {
    $session = New-CimSession -ComputerName $server -Credential $admin
    $CIM = Get-CimInstance -CimSession $session -ClassName win32_operatingsystem
    $CIM | select CSName,LastBootUpTime
}
