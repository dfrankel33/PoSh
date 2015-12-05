<# 
.SYNOPSIS 
   This is the top level script to run vCheck in a foreach loop.  For more information
   on vCheck, run: get-help .\vcheck.ps1

.DESCRIPTION
   Run the full help to see parameters that can be set. 

.NOTES 
   File Name  : Execute_vCheck.ps1 
   Author     : Dave Frankel
   Version    : 1.0
    
.PARAMETER csv
   If this switch is set, define a CSV to import a list of target hosts. CSV headers should
   be: ESX, Admin, Credential
   
#>

param ( $CSV )
if ($CSV -eq $null){$CSV = "C:\vCheck_DF\Default_Hosts.csv"}
$virtualhosts=import-csv $CSV

function Import-PSCredential {
        param ( $Path )<# = "C:\vCheck_DF\windowscreds.enc.xml" #>
 
        # Import credential file
        $import = Import-Clixml $Path
       
        # Test for valid import
        if ( !$import.UserName -or !$import.EncryptedPassword ) {
                Throw "Input is not a valid ExportedPSCredential object, exiting."
        }
        $Username = $import.Username
       
        # Decrypt the password and store as a SecureString object for safekeeping
        $SecurePass = $import.EncryptedPassword | ConvertTo-SecureString
       
        # Build the new credential object
        $Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePass
        Write-Output $Credential
}

foreach ($virtualhost in $virtualhosts)
    {
    $Server = $virtualhost.ESX
    $EmailTo = $virtualhost.Admin
    $Credfile = $VirtualHost.Credential
    $EmailCC = $VirtualHost.CC
    .\vCheck.ps1
    }
