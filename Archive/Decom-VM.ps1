
Function Decom-VM  {
     param
     (
         [Parameter(Mandatory=$true,Position=1)]
         [string]
         $Name,

         [string]
         $VMPath,

         [Parameter(Mandatory=$true)]
         [string]
         $VMMServer,

         [string]
         $VMHost,

         [string]
         $Cluster,

         [string]
         $SCCMServer,

         [string]
         $SCOMServer,

         [string]
         $DomainController,

         [string]
         $To,

         [string]
         $From,

         [string]
         $SMTPServer,

         [string]
         $LogPath
     )

     If (!$LogPath){$LogPath = 'C:\PSCode\DecomVMs\'}
     $LogFile = "$(get-date -UFormat %Y%m%d)_$($Name)_DECOM.txt"
     $Log = "$LogPath$LogFile"

     Write-Output "*******************DECOMMISSIONNING OF $Name*******************" | Out-File $Log
     Write-Output '' | out-file $Log -Append
     Write-Output "Executed by: $env:USERNAME"  | Out-File $Log -Append
     Write-Output '' | out-file $Log -Append

     #Check for multiple VMs with the same name
     $SCVM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $Name 
     $Count = $SCVM | Measure-Object
     If ($($Count.Count) -gt 1) {Write-Output "WARNING: $($Count.Count) VMs with the name $Name exist on this SCVMM Server. Cancelling Script..." | Tee-Object $Log -Append
     Break}

     #Decommission VM from SCVMM
     If (!$SCVM) {Write-Output "WARNING: $Name Does Not Exist in SCVMM" | Tee-Object $Log -Append } else {
     $SCVM | Remove-SCVirtualMachine } #-whatif}

     #Check for VM in FCM and remove if present
     $ClusRes = Get-ClusterResource -Cluster $Cluster -Name "*$Name*"
     If (!$ClusRes) {Write-Output "WARNING: $Name Does Not Exist on the $Cluster Cluster" | Tee-Object $Log -Append } else {
     $ClusRes | Remove-ClusterResource } #-WhatIf}

     #Check for VM in Hyper-V and remove if present
     $HyperVM = hyper-v\Get-VM -Name $Name -ComputerName $VMHost
     If (!$HyperVM) {Write-Output "WARNING: $Name Does Not Exist on the $VMHost Node" | Tee-Object $Log -Append } else {
     $HyperVM | hyper-v\Remove-VM } #-WhatIf}

     #Check for data on CSV and remove if present
     $loc = $VMPath.Split('\')
     $VMData = "\\$VMHost\C$\$($loc[1])\$($loc[2])\$($loc[3])\"
     if (!$(Test-Path -Path $VMData\*)) {Write-Output "WARNING: $Name Does Not Exist on the $VMPath CSV on $Cluster" | Tee-Object $Log -Append } else {
     Remove-Item -Path $VMData -Recurse -Force -Confirm:$false } #-WhatIf}

     #Disable AD Computer Object
     if ($DomainController) {
         $ADObject = Get-ADComputer $Name -Server $DomainController
         if ($($ADObject.Enabled) -eq $false) {Write-Output "WARNING: $Name is already disabled in $ENV:USERDNSDOMAIN Active Directory." | Tee-Object $Log -Append } else {
         $ADObject | Disable-ADAccount -Confirm:$false } #-WhatIf }
     }
     #Remove SCCM Object
     if ($SCCMServer) {
         $SCCMSiteCode = 'P01'
         $Resource = (Get-WmiObject -Class SMS_R_SYSTEM -Namespace root\sms\site_$SCCMSiteCode -ComputerName $SCCMServer -Filter "Name = '$Name'").__PATH
         Remove-WmiObject -InputObject $Resource #-WhatIf
     }

     #Remove SCOM Object
     if ($SCOMServer) {
         $SCOMobject = Get-SCOMAgent -Name "$Name.$ENV:USERDNSDOMAIN" -ComputerName $SCOMServer
         If(!$SCOMobject){Write-Output "WARNING: Computer object not found in SCOM Console on $SCOMServer" | Tee-Object $Log -Append} else {
        $SCOMobject | Uninstall-SCOMAgent } #-WhatIf }
     }

     #Email Results
     If($To -and $From -and $SMTPServer) {
         $message = New-Object System.Net.Mail.MailMessage $From, $To
         $message.Subject = "Decommission Log of $Name - $(get-date -Format dd-MMM-yyyy)"
         $message.Attachments.Add($Log)
         $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
         $smtp.Send($message)
     }
     else {
        Write-Output 'Log File not emailed.' | Tee-Object $Log -Append
     }
}