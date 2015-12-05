#Script to test list of hostnames & ip addresses to confirm whether they are ESX/ESXi hosts

function Test-TcpPortConnection {
    param($server,$port)
    try{
    $socket = New-Object System.Net.Sockets.TcpClient
    $socket.Connect($server,$port)
    $socket.Close()
    return New-Object PSObject -Property @{
        Server=$server;
        Pass=$true;
        Exception=$null;
    }
}

catch [System.ArgumentNullException] { 
        return New-Object PSObject -Property @{ 
            Server=$server;
            Pass=$false; 
            Exception="Null argument passed"; 
        } 
    } 
    catch [ArgumentOutOfRangeException] { 
        return New-Object PSObject -Property @{ 
            Server=$server;
            Pass=$false; 
            Exception="The port is not between MinPort and MaxPort"; 
        } 
    } 

catch [System.Net.Sockets.SocketException] { 
        return New-Object PSObject -Property @{ 
            Server=$server;
            Pass=$false; 
            Exception="Socket exception"; 
        }        
    } 
    catch [System.ObjectDisposedException] { 
        return New-Object PSObject -Property @{ 
            Server=$server;
            Pass=$false; 
            Exception="TcpClient is closed"; 
        } 
    } 
 
catch { 
        return New-Object PSObject -Property @{ 
            Server=$server;
            Pass=$false; 
            Exception="Unhandled Error"; 
        }    
    } 
}

$CSV = Read-Host "Enter the path of the CSV file to scan against.  Note there should be 2 columns.  One called 'Hostname' and another called 'IP' "

$failures= @()
$successes= @()
$PCs = Import-CSV $CSV 
foreach ($PC in $PCs) 
{
    if ((Test-TcpPortConnection -server $PC.hostname -port 902).Pass -eq $false) 
    {
    write-host $PC.hostname "could not be contacted on port 902"
    $failures = $failures + @($PC.hostname)
    }
    else 
    {
    #write-host $PC.hostname "is a vSphere host!" 
    $successes = $successes + @($PC.hostname)
    }
}
#hyper-v check
$CSV = Read-Host "Enter the path of the CSV file to scan against.  Note there should be 2 columns.  One called 'Hostname' and another called 'IP' "

$hypervfail= @()
$hypervsuccess= @()
$PCs = Import-CSV $CSV 
foreach ($PC in $PCs) 
{
    if ((Test-TcpPortConnection -server $PC.hostname -port 2179).Pass -eq $false) 
    {
    write-host $PC.hostname "could not be contacted on port 2179"
    $hypervfail = $hypervfail + @($PC.hostname)
    }
    else 
    {
    #write-host $PC.hostname "is a hyper-v host!" 
    $hypervsuccess = $hypervsuccess + @($PC.hostname)
    }
}

foreach ($failure in $failures)
{
$pingtest = Test-Connection $failure -count 1 -Quiet
if ($pingtest -ne $true)
    {
    write-host "$failure is not responding to ping requests"
    }
    else
        {
        if ((Test-TcpPortConnection -server $failure -port 902).Pass -eq $false) 
        {
        write-host $failure "could not be contacted on port 902"
        }
        else 
            {
            write-host $failure "is a vSphere host!"
            $successes = $successes + @($failure)
            }
        }
}
