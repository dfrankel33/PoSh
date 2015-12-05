#Load PowerCLI SnapIn
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null ) 
{ 
try{Add-PSSnapin VMware.VIMAutomation.Core}  # Add the VMware PowerCLI Snap-In
catch{Catch-Processing-Exit}
}

#Import Cred Function
function Import-PSCredential {
        param ( $Path )
 
        # Import credential file
        $import = Import-Clixml $Path
       
        # Test for valid import
        if ( !$import.UserName -or !$import.EncryptedPassword ) {
                Throw 'Input is not a valid ExportedPSCredential object, exiting.'
        }
        $Username = $import.Username
       
        # Decrypt the password and store as a SecureString object for safekeeping
        $SecurePass = $import.EncryptedPassword | ConvertTo-SecureString
       
        # Build the new credential object
        $Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePass
        Write-Output $Credential
}

#Static Variables
$strlogpath = 'C:\PSCode\'
$oDate = get-date -UFormat %Y%m%d
$strOutput = "C:\PSCode\HypervisorDisc_$oDate.csv"

#Import list of VMware hosts
$aHypervisors = $null
$aHypervisors = Import-Csv -Path C:\PSCode\hypervisors.csv

#Define Credentials
$oRootCred = Import-PSCredential -Path C:\PSCode\rootcred.enc.xml

#Disable Certificate Callback -- re-enabled at end of script
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

#Define Arrays
$aResult = @()

Foreach ($oHypervisor in $aHypervisors) {
    $error.Clear()
    
    #Establish Connection to ESXi Host
    Connect-VIServer -Server $($oHypervisor.Hostname) -credential $oRootCred

    #Get CPU Info
    $oCPU = $null
    $oCPU = get-view -ViewType HostSystem -Property Hardware.CPUInfo -ErrorAction SilentlyContinue | Select @{n="NumCpuSockets"; e={$_.Hardware.CpuInfo.NumCpuPackages}}, @{n="NumCpuCores"; e={$_.Hardware.CpuInfo.NumCpuCores}}, @{n="NumCpuThreads"; e={$_.Hardware.CpuInfo.NumCpuThreads}}
    
    #Get VM Count and Status
    $aVMs = @()
    $aOnVMs = @()
    $aOffVMs = @()
    $aVMs = VMware.VimAutomation.Core\Get-VM | select name,powerstate,@{N="Host";E={$oHypervisor.hostname}}
    $aOnVMs = $aVMs | where {$_.powerstate -eq "PoweredOn"} | measure
    $aOffVMs = $aVMs | where {$_.powerstate -eq "PoweredOff"} | measure
    
    $oStats = $null
    $oStats = New-Object psobject
    $oStats | Add-Member -MemberType NoteProperty -Name Host -Value $($oHypervisor.hostname)
    $oStats | Add-Member -MemberType NoteProperty -Name CPUSockets -Value $oCPU.NumCpuSockets
    $oStats | Add-Member -MemberType NoteProperty -Name CPUCores -Value $oCPU.NumCpuCores
    $oStats | Add-Member -MemberType NoteProperty -name CPUThreads -Value $oCPU.NumCpuThreads
    $oStats | Add-Member -MemberType NoteProperty -Name OnVMs -Value $aOnVMs.Count
    $oStats | Add-Member -MemberType NoteProperty -Name OffVMs -Value $aOffVMs.Count

    $aResult += $oStats
    
    Disconnect-VIServer * -Confirm:$false
    }



    $aResult | Export-Csv $strOutput -Append

#Enable Certificate Callback
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$null}
