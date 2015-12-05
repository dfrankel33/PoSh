function Test-TcpPortConnection {
    param($server,$port)
    try{
    $socket = New-Object System.Net.Sockets.TcpClient
    $socket.Connect($server,$port)
    $socket.Close()
    return New-Object PSObject -Property @{
        Pass=$true;
        Exception=$null;
    }
}

catch [System.ArgumentNullException] { 
        return New-Object PSObject -Property @{ 
            Pass=$false; 
            Exception="Null argument passed"; 
        } 
    } 
    catch [ArgumentOutOfRangeException] { 
        return New-Object PSObject -Property @{ 
            Pass=$false; 
            Exception="The port is not between MinPort and MaxPort"; 
        } 
    } 

catch [System.Net.Sockets.SocketException] { 
        return New-Object PSObject -Property @{ 
            Pass=$false; 
            Exception="Socket exception"; 
        }        
    } 
    catch [System.ObjectDisposedException] { 
        return New-Object PSObject -Property @{ 
            Pass=$false; 
            Exception="TcpClient is closed"; 
        } 
    } 
 
catch { 
        return New-Object PSObject -Property @{ 
            Pass=$false; 
            Exception="Unhandled Error"; 
        }    
    } 
}