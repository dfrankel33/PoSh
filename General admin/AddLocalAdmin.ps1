#Script to add user account to local administrators group


#Initial Prompt
Write-Host "This script will add a user account to the local administrators group of a server or list of servers." -BackgroundColor DarkRed
Write-Host ""
Write-Host "Please ensure that only -LA accounts are granted access to servers, in accord with current BIS policy." -BackgroundColor DarkRed
Write-Host ""

#Input Username
$NetBIOS = Read-Host "Enter domain NetBIOS name"
$SAM = Read-Host "Enter $NetBIOS SamAccountName to add to local admin group"
Write-Host ""

#Define Server Input Method
$InputMethod = Read-Host "Single server? [1] or CSV List [2]?"

    #Single Server
    If ($InputMethod -eq 1)
        {
        $target = Read-Host "enter hostname of server"
        $objUser = [ADSI]("WinNT://$NetBIOS/$SAM")
        $objGroup = [ADSI]("WinNT://$target/Administrators")
        $objGroup.PSBase.Invoke("Add",$objUser.PSBase.Path)
        }

    #Multiple Servers
    ElseIf ($InputMethod -eq 2)
        {
        Write-Warning "CSV must have the hostname of the servers in a column titled 'Name'"
        $CSV = Read-Host "Enter Full Path to CSV"
        Import-Csv $CSV | ForEach {
            $Target = $_.Name
            $objUser = [ADSI]("WinNT://$NetBIOS/$SAM")
            $objGroup = [ADSI]("WinNT://$Target/Administrators")
            $objGroup.PSBase.Invoke("Add",$objUser.PSBase.Path)
            }
        }


    Else 
        {
        Write-Warning "Incorrect input.  Breaking script..."
        Break
        }