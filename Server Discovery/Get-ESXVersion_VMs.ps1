# The script below is to be run within a VMware PowerCLI shell.
# Author: Dave Frankel
# Last Edited: 7/6/2015

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
$strlogpath = 'C:\PSCode\SNOWLogs\'
$oDate = get-date -UFormat %Y%m%d
New-Item -Path $strlogpath -ItemType Directory -ErrorAction SilentlyContinue
$strlogfile = "C:\PSCode\SNOWLogs\Log_$oDate.txt"
$strOutput1 = "C:\PSCode\SNOWLogs\VersionCheck_$oDate.csv"
$strOutput2 = "C:\PSCode\SNOWLogs\VMsCheck_$oDate.csv"

#Import list of VMware hosts
$aHypervisors = $null
$aHypervisors = Import-Csv -Path C:\PSCode\SNOWLogs\hypervisors.csv

#Define Credentials
$oRootCred = Import-PSCredential -Path C:\PSCode\rootcred.enc.xml

#Disable Certificate Callback -- re-enabled at end of script
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

#Define Arrays
$aVersion = @()
$aVMS = @()

Foreach ($oHypervisor in $aHypervisors) {
    $error.Clear()
    
    #Establish Connection to ESXi Host
    Connect-VIServer -Server $($oHypervisor.Hostname) -credential $oRootCred

    #Get ESX Version
    $oVersion = $null
    $oVersion = get-view -ViewType HostSystem -Property Name, Config.Product | select @{N="Host";E={$oHypervisor.hostname}},@{N="ESX_Version";E={$_.Config.Product.FullName}}
    $aVersion += $oVersion

    #Get VMs and Status
    $aVMStatus = @()
    $oVMStatus = $null
    $aVMStatus = VMware.VimAutomation.Core\Get-VM | select name,powerstate,@{N="Host";E={$oHypervisor.hostname}}
    Foreach ($oVMStatus in $aVMStatus) {
        $aVMS += $oVMStatus
    }

    #LogIt
#    Write-Output ' ' | Tee-Object -FilePath $strlogpath -Append
#    Write-Output $error | Tee-Object -FilePath $strlogpath -Append
    Disconnect-VIServer $oHypervisor.Hostname -Confirm:$false
    }

    $aVersion | Export-Csv $strOutput1 -Append
    $aVMs | Export-CSV $strOutput2 -Append

#Enable Certificate Callback
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$null}
 

#Fails
Foreach ($oHypervisor in $aHypervisors) {
    $error.Clear()
   

    #Get ESX Version
    $oVersion = $null
    $oVersion = Get-ESX -Server $oHypervisor -Credential $oRootCred | select name,build
    $aVersion += $oVersion

}