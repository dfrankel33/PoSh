

function Check-Version {
    param (

        [Parameter(Mandatory=$true)]
        [string]
        $WebURI,

        [Parameter(Mandatory=$true)]
        [string]
        $TestVersion

    )

    $CurrentVersion = $(Invoke-WebRequest -Uri $WebURI).Content

    If ($TestVersion -lt $CurrentVersion) { 
        Write-Output 'WARNING: You are using an outdated version of this module.'
        Write-Output 'Please update the version on your computer and try again.'
        break
    }
}

function Deploy-VM { 
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $VMMServer,

        [Parameter(Mandatory=$true)]
        [string]
        $VMName,

        [Parameter(Mandatory=$true)]
        [string]
        $Description,

        [Parameter(Mandatory=$true)]
        [string]
        $Site,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Production','DMZ','Staging','Management','SQL')]
        [string]
        $Cluster,

        [Parameter(Mandatory=$true)]
        [ValidateSet('2008','2008R2','2012R2')]
        [string]
        $OS,

        [Parameter(Mandatory=$true)]
        [int16]
        $CPU,

        [Parameter(Mandatory=$true)]
        [int16]
        $Memory,

        [Parameter(Mandatory=$false)]
        [int64]
        $AdditionalHDD1Size,

        [Parameter(Mandatory=$false)]
        [int64]
        $AdditionalHDD2Size,

        [Parameter(Mandatory=$false)]
        [int64]
        $AdditionalHDD3Size,

        [Parameter(Mandatory=$false)]
        [ValidateSet('N/A','Bronze','Silver','Gold','Platinum')]
        [string]
        $DRServiceLevel,

        [Parameter(Mandatory=$true)]
        [string]
        $Division,

        [Parameter(Mandatory=$true)]
        [string]
        $DomainController,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.CredentialAttribute()]
        $Credential

    )


if ($PSVersionTable.PSVersion.Major -lt '3'){
    Write-Warning 'You must be running PowerShell version 3 or higher to execute this function'
    Start-Sleep 10
    Exit
    }

###############################################################################################
#########################################    EDIT     #########################################
#########################################   OU  DN    #########################################
#########################################   STRING    #########################################
###############################################################################################
#Confirm Ops Admin
$admins = @()
$admins = Get-ADUser -Filter * -SearchBase 'OU DN'

if ($Credential.UserName -like "*\*") {$admin = $Credential.UserName.Split("\")[1]}
    else {
        Write-Warning 'Username must be in syntax of NetBIOS\USERNAME'
        Start-Sleep 10
        exit
    }

if (!$(Compare-Object -ReferenceObject $admins.samaccountname -DifferenceObject $admin -ExcludeDifferent -IncludeEqual))
    {
    Write-Warning 'Credential provided is not a member of Operations Admins.  This console will close.'
    Start-Sleep 10
    exit
    }

###############################################################################################
#########################################    EDIT     #########################################
#########################################   WEBURI    #########################################
#########################################   STRING    #########################################
###############################################################################################
#Check for Updates
$FunctionVersion = '1.1'
Check-Version -WebURI '' -TestVersion $FunctionVersion

#All the Action
[System.Management.Automation.ScriptBlock]$ScriptBlock = { 
$strJobGroupID = [Guid]::NewGuid().ToString()

$strSCCloud = $null


###############################################################################################
#########################################     ALL     #########################################
######################################### PROPRIETARY #########################################
#########################################    INFO     #########################################
#########################################   REMOVED   #########################################
###############################################################################################
#########################################    EDIT     #########################################
#########################################    EMPTY    #########################################
#########################################   STRINGS   #########################################
###############################################################################################
#Define Cloud
if ($Site -eq '')
{
	if ($Cluster -eq 'Production') { $strSCCloud = '' }
	if ($Cluster -eq 'Staging') { $strSCCloud = '' }
	if ($Cluster -eq 'Management') { $strSCCloud = '' }
	if ($Cluster -eq 'DMZ') { $strSCCloud = '' }
    if ($Cluster -eq 'SQL') { $strSCCloud = '' }
}
if ($Site -eq '')
{
	if ($Cluster -eq 'Production') { $strSCCloud = '' }
	if ($Cluster -eq 'Staging') { $strSCCloud = '' }
	if ($Cluster -eq 'Management') { $strSCCloud = '' }
	if ($Cluster -eq 'DMZ') { $strSCCloud = '' }
    if ($Cluster -eq 'SQL') { $strSCCloud = '' }
}

#Define GuestOS Profile, Hareware Profile, & VM Template
if ($strSCCloud -clike '*DMZ*') {
    if ($Site -eq 'CUSC'){
	    if ($OS -eq '2008') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2008R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2012R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
        }
    if ($Site -eq ''){
	    if ($OS -eq '2008') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2008R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2012R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
        }
    } 
else {
    if ($Site -eq ''){
	    if ($OS -eq '2008') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2008R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2012R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
        }
    if ($Site -eq ''){
	    if ($OS -eq '2008') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2008R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
	    if ($OS -eq '2012R2') { 
            $oGuestOSProfile = Get-SCGuestOSProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oHardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where-object {$_.Name -clike ''}
            $oVMTemplate = Get-SCVMTemplate -VMMServer $VMMServer | Where-Object {$_.Name -clike ''}
            }
        }
    }

#Define remaining variables
$oPortClassification = Get-SCPortClassification -VMMServer $VMMServer | Where-Object {$_.Name -eq 'Default'}
New-SCVMTemplate -Name "Temporary Template - $VMName" -Template $oVMTemplate -HardwareProfile $oHardwareProfile -GuestOSProfile $oGuestOSProfile -JobGroup $strJobGroupID 
$oTempTemplate = get-scvmtemplate -vmmserver $VMMServer -All | Where-Object {$_.Name -eq "Temporary Template - $VMName" }
$oVMConfig = New-scvmconfiguration -Name $VMName -VMTemplate $oTempTemplate
$intMemoryMB = $Memory * 1024
$strVMStartAction = 'TurnOnVMIfRunningWhenVSStopped'
$oOps = Get-SCUserRole -VMMServer $VMMServer -Name ''
$oSCCloud = Get-SCCloud -VMMServer $VMMServer -Name $strSCCloud

#Build VM
New-SCVirtualMachine -Name $VMName -VMConfiguration $oVMConfig -Cloud $oSCCloud -ComputerName $VMName -CPUCount $CPU -Description $Description -MemoryMB $intMemoryMB -SelfServiceRole $oOps -StartAction $strVMStartAction -JobGroup $strJobGroupID


Start-Sleep -Seconds 120

#$VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $VMName
do {
    Start-Sleep -Seconds 5
    $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $VMName
    } while (!$VM)


$strJobGroupID2 = [Guid]::NewGuid().ToString()
#Add additional HDDs
if ($AdditionalHDD1Size) {
    $intHDD1Size = $AdditionalHDD1Size * 1024 
    New-SCVirtualDiskDrive -VM $VM -Dynamic -Bus 0 -LUN 2 -SCSI -VirtualHardDiskSizeMB $intHDD1Size -VMMServer $VMMServer -FileName $VMName"_Disk2" #-JobGroup $strJobGroupID2
    }

if ($AdditionalHDD2Size) {
    $intHDD2Size = $AdditionalHDD2Size * 1024 
    New-SCVirtualDiskDrive -VM $VM -Dynamic -Bus 0 -LUN 3 -SCSI -VirtualHardDiskSizeMB $intHDD2Size -VMMServer $VMMServer -FileName $VMName"_Disk3" #-JobGroup $strJobGroupID2
    }

if ($AdditionalHDD3Size) {
    $intHDD3Size = $AdditionalHDD3Size * 1024 
    New-SCVirtualDiskDrive -VM $VM -Dynamic -Bus 0 -LUN 4 -SCSI -VirtualHardDiskSizeMB $intHDD3Size -VMMServer $VMMServer -FileName $VMName"_Disk4" #-JobGroup $strJobGroupID2
    }

#Set DR and Backup property values
$oDRServiceLevel = Get-SCCustomProperty -VMMServer $VMMServer | Where-Object {$_.Name -clike 'DR_Service_Level'}
$oDivision = Get-SCCustomProperty -VMMServer $VMMServer | Where-Object {$_.Name -like 'Division'}
if ($DRServiceLevel) {
    Set-SCCustomPropertyValue -CustomProperty $oDRServiceLevel -InputObject $VM -Value $DRServiceLevel #-JobGroup $strJobGroupID2
}
if ($Division) {
    Set-SCCustomPropertyValue -CustomProperty $oDivision -InputObject $VM -Value $Division #-JobGroup $strJobGroupID2
}

#Share with Ops User Role
Grant-SCResource -Resource $VM -UserRoleName $oOps

Start-VM $VM

#CleanUp
$VMConfig = Get-SCVMConfiguration -VMMServer $VMMServer -All | Where-Object {$_.Name -eq "$VMName"} 
If ($VMConfig) { $VMConfig | Remove-SCVMConfiguration }
$VMTemp = Get-SCVMTemplate -VMMServer $VMMServer -Name "Temporary Template - $VMName" 
If ($VMTemp) { $VMTemp | Remove-SCVMTemplate }
} #end $ScriptBlock

#Check if remoting is necessary & execute
if ($VMMServer -eq $ENV:ComputerName) {$ScriptBlock.Invoke()}
    elseif ($VMMServer -eq "$ENV:ComputerName.$ENV:USERDNSDOMAIN") {$ScriptBlock.Invoke()}
    else {
        $AllSessions = Get-PSSession 
        if ($AllSessions) { $AllSessions | Remove-PSSession }
        New-PSSession -ComputerName $VMMServer -Credential $Credential
        $Session = Get-PSSession -ComputerName $VMMServer -Credential $Credential
        Invoke-Command -Session $Session -ScriptBlock {
            $VMMServer = $Using:VMMServer
            $VMName = $Using:VMName
            $Description = $Using:Description
            $Site = $Using:Site
            $Cluster = $Using:Cluster
            $OS = $Using:OS
            $CPU = $Using:CPU
            $Memory = $Using:Memory
            $AdditionalHDD1Size = $Using:AdditionalHDD1Size
            $AdditionalHDD2Size = $Using:AdditionalHDD2Size
            $AdditionalHDD3Size = $Using:AdditionalHDD3Size
            $DRServiceLevel = $Using:DRServiceLevel
            $BackupRequirement = $Using:BackupRequirement
            Invoke-Expression -Command $Using:ScriptBlock
            }
        Remove-PSSession -Session $Session
        }

    #AD CleanUp
    if ($Cluster -ne 'DMZ') {
        If ($Site -eq '') {
            if ($Cluster -eq 'Staging') {$DestPath = ''}
            if ($Cluster -eq 'Production') {$DestPath = ''}
            if ($Cluster -eq 'Management') {$DestPath = '' }
            if ($Cluster -eq 'SQL') {$DestPath = '' }
            }
        If ($Site -eq '') {
            if ($Cluster -eq 'Staging') {$DestPath = ''}
            if ($Cluster -eq 'Production') {$DestPath = ''}
            if ($Cluster -eq 'Management') {$DestPath = '' }
            if ($Cluster -eq 'SQL') {$DestPath = '' }
            }
        New-PSSession -ComputerName $DomainController -Credential $Credential
        $DCSession = Get-PSSession -ComputerName $DomainController -Credential $Credential
        $DCScriptBlock = {
                do {
                    Start-Sleep -Seconds 5
                    $ADObject = Get-ADComputer -Identity $AdComp -ErrorAction SilentlyContinue
                    } while (!$ADObject)

                $ADObject | Set-ADComputer -Description "$ADDesc"
                Move-ADObject -Identity $ADObject.DistinguishedName -TargetPath $ADPath
            }
        Invoke-Command -Session $DCSession -ScriptBlock { 
                $ADDesc = $Using:Description
                $ADComp = $Using:VMName
                $ADPath = $Using:DestPath
                Invoke-Expression -Command $Using:DCScriptBlock
                }
        Remove-PSSession -Session $Session
    } 

}#end deploy-vm function




