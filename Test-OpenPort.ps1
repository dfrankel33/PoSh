<# param( 
 [String]$server="10.17.128.10"  
, 
 [String]$port=902 
) 
$socket = new-object Net.Sockets.TcpClient 
$socket.Connect($server, $port) 
if ($socket.Connected) { 
$status =  "Open"
$socket.Close() 
} 
else { 
$status = "Not Open" 
} 
$status

Function test-OpenPort { 
param( [String]$server="10.17.128.10", 
 [String]$port="902" ) 
$socket = new-object Net.Sockets.TcpClient 
$socket.Connect($server, $port)  
if ($socket.Connected) { 
$status = "$Server has port $port Open" 
$socket.Close() 
} 
else { 
$status = "Not Open" 
} 
try {Test-Connection $server -Count 1 -Quiet}
catch {}
$status 
}

Function test-OpenPort { 
param( [String]$server="10.17.128.10", 
 [String]$port="902" ) 
    try {test-connection -ComputerName $server -count 1|out-null 
        $socket = new-object Net.Sockets.TcpClient 
        $socket.Connect($server, $port)  
        if ($socket.Connected) { 
            $status = "$Server has port $port Open" 
        $socket.Close() 
        } 
        else {
        $status = "$server Port Closed"
        } 
    
    } catch { 
    } finally { $status ; remove-variable socket } 
} 
#>
Function test-OpenPort { 
param( [String]$server="localhost", 
 [String]$port="902" ) 
    try {test-connection -ComputerName $server -count 1 |out-null } 
    catch [System.Net.NetworkInformation.Ping] {write-warning "Host not responding to ping" ; break} 
    try { $socket = new-object Net.Sockets.TcpClient 
        $socket.Connect($server, $port) } 
    catch [System.Net.Sockets.SocketException] {write-warning "Host was present; socket not connected" } 
        
        if ($socket.Connected) { 
            $status = "$Server has port $port Open" 
        $socket.Close() 
        } 
        else { $status = "$Server Not Open"} 
    
write-output $status ; remove-variable socket } 

