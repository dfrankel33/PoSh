<# 
.SYNOPSIS 
    This script contains functions that are intended to provide monitors for servers that are not monitored by SCOM. See the Description for the full list of functions available in this script. For proper error reporting, the target VM should be added to the SMTP Relay Allowed List.

.DESCRIPTION
   Each function has it's own Help and examples.  Execute: Get-Help [Function] to see it.  The list of functions included in this script are:

   Monitor-CPU
   Monitor-RAM
   Monitor-Disk
   Monitor-Service
   Monitor-Process
   Monitor-WebSite

.NOTES 
   File Name  : _Monitors.ps1 
   Author     : Dave 
   Version    : 1.0
    
   
#>


#Monitor CPU
Function Monitor-CPU {
     <#
     .SYNOPSIS
     This function scans the % CPU Time of a specified CPU or the average of all CPUs.  

     .DESCRIPTION
     If parameters are not set otherwise, the scan will query every minute for 30 minutes. The Get-Counter cmdlet is used to determine the CookedValue of the % Processor Time counter.  Unless otherwise specified, errors will be triggers if the average % Processor Time exceeds 85%.

     .NOTES
     Function Name  : Monitor-CPU 
     Author     : Dave 
     Version    : 1.0

     .PARAMETER CPU
     This parameter is to identify the specific CPU to monitor.  For example, if a server has 4 vCPU, the value can be 1, 2, 3, or 4.  If the parameter is not set when executing the function, it will default to "_total", which will return the average % CPU Time of the server.

     .PARAMETER Threshold
     This parameter determines what the threshold should be for error reporting.  If a value is not set for this parameter when executing the function, it will default to "85%"

     .PARAMETER SampleInterval
     Specifies the time between samples in seconds. The minimum value is 1 second and the default value is 60 seconds.

     .PARAMETER MaxSamples
     Specifies the number of samples to get from each counter. The default is 30 samples. 

     .PARAMETER SendMail
     This boolean parameter determines whether errors should be reported via email.  It will default to $false unless explicitly set to $true.

     .PARAMETER To
     This parameter defines the send-to address for any error reporting.  If this is not set, the SendMail parameter will revert to $false, regardless of if it was set to $true.

     .EXAMPLE
     Monitor-CPU
     This command will monitor the "_total" CPU time, since a specific CPU wasn't set.  It will scan every 60 seconds for 30 minutes, since neither of those values were set.  If the average processor time exceeds 85% (since the threshold variable wasn't set), it will log the event.  No email will be sent.

     .EXAMPLE
     Monitor-CPU -Threshold 40 -SampleInterval 15 -MaxSamples 30 -SendMail $true -to Operations@contoso.com
     This command will monitor the "_total" CPU time, since a specific CPU wasn't set.  It will scan every 15 seconds, 30 times.  If the average processor time exceeds 40% it will log the event and send an email to Operations@contoso.com.

     #>
     param
     (
         [int]
         $CPU,

         [int]
         $Threshold,

         [int]
         $SampleInterval,

         [int]
         $MaxSamples,

         [bool]
         $SendMail,

         [string]
         $To
     )

     #Set Error Log Path
     if ($(Test-Path C:\PSCode) -eq $false) { New-Item -Path C:\ -Name PSCode -ItemType Directory }
     if ($(Test-Path C:\PSCode\Monitor-CPU) -eq $false) { New-Item -Path C:\PSCode\ -Name Monitor-CPU -ItemType Directory }
     $logpath = 'C:\PSCode\Monitor-CPU\'
     $logfile = "$(Get-Date -UFormat %Y-%m-%d_%H%M)_Monitor-CPU_LOG.txt"
     $log = "$logpath$logfile"
     
     #Set Variables if not defined when executing the function
     If ($SendMail -ne $true) { $SendMail = $false }
     If (!$To) { $SendMail = $false }
     If ($SendMail -eq $true) {
        #Set Static Variables
        $From = ""
        $SMTPServer = ''        
        }
     If (!$CPU) { [string]$CPU = '_total' }
     If (!$Threshold) { $Threshold = '85' }
     If (!$SampleInterval) { $SampleInterval = '60' }
     If (!$MaxSamples) { $MaxSamples = '30' }



     #Scan
     $CookedValue = $(Get-Counter -Counter "\Processor($CPU)\% Processor Time" -SampleInterval $SampleInterval -MaxSamples $MaxSamples).CounterSamples.CookedValue
     Foreach ($Value in $CookedValue){ $TotalValue += $Value }
     $Result = $TotalValue / $MaxSamples

     #LogIt
     If ($Result -gt $Threshold) {
        Write-Output '************ERROR LOG************' | Out-File $Log
        Write-Output "Computer: $ENV:COMPUTERNAME" | Out-File $Log -Append
        Write-Output "CPU: $CPU" | Out-File $Log -Append
        Write-Output "Threshold: $Threshold" | Out-File $Log -Append
        Write-Output "Scan Interval: Scanned every $SampleInterval seconds.  Completed $MaxSamples scans." | Out-File $Log -Append
        Write-Output "Average % Processor Time: $Result" | Out-File $Log -Append
        $LogContent = Get-Content $Log

        If ($SendMail -eq $True) {
            $message = New-Object System.Net.Mail.MailMessage $From, $To
            $message.Subject = "New Alert: CPU Threshold Reached on $ENV:COMPUTERNAME"
            $message.IsBodyHTML = $true
            $message.Body = $LogContent | ConvertTo-Html 
            $message.Attachments.Add($Log)
            $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
            $smtp.Send($message)
            }

        }


}

Function Monitor-RAM {
     <#
     .SYNOPSIS
     This function scans the server's memory for the "% Committed Bytes in Use" value.  

     .DESCRIPTION
     If parameters are not set otherwise, the scan will query every minute for 30 minutes. The Get-Counter cmdlet is used to determine the CookedValue of the % Committed Bytes in Use counter.  Unless otherwise specified, errors will be triggers if the average value exceeds 80%.

     .NOTES
     Function Name  : Monitor-RAM 
     Author     : Dave 
     Version    : 1.0

     .PARAMETER Threshold
     This parameter determines what the threshold should be for error reporting.  If a value is not set for this parameter when executing the function, it will default to "80%"

     .PARAMETER SampleInterval
     Specifies the time between samples in seconds. The minimum value is 1 second and the default value is 60 seconds.

     .PARAMETER MaxSamples
     Specifies the number of samples to get from each counter. The default is 30 samples. 

     .PARAMETER SendMail
     This boolean parameter determines whether errors should be reported via email.  It will default to $false unless explicitly set to $true.

     .PARAMETER To
     This parameter defines the send-to address for any error reporting.  If this is not set, the SendMail parameter will revert to $false, regardless of if it was set to $true.

     .EXAMPLE
     Monitor-RAM
     This command will monitor the Memory's % Committed Bytes in Use.  It will scan every 60 seconds for 30 minutes, since neither of those values were set.  If the average exceeds 80% (since the threshold variable wasn't set), it will log the event.  No email will be sent.

     .EXAMPLE
     Monitor-RAM -Threshold 40 -SampleInterval 15 -MaxSamples 30 -SendMail $true -to Operations@contoso.com
     This command will monitor the Memory's % Committed Bytes in Use.  It will scan every 15 seconds, 30 times.  If the average exceeds 80% it will log the event and send an email to Operations@contoso.com.

     #>
      param
     (
         [int]
         $Threshold,

         [int]
         $SampleInterval,

         [int]
         $MaxSamples,

         [bool]
         $SendMail,

         [string]
         $To
     )

     #Set Error Log Path
     if ($(Test-Path C:\PSCode) -eq $false) { New-Item -Path C:\ -Name PSCode -ItemType Directory }
     if ($(Test-Path C:\PSCode\Monitor-RAM) -eq $false) { New-Item -Path C:\PSCode\ -Name Monitor-RAM -ItemType Directory }
     $logpath = 'C:\PSCode\Monitor-RAM\'
     $logfile = "$(Get-Date -UFormat %Y-%m-%d_%H%M)_Monitor-RAM_LOG.txt"
     $log = "$logpath$logfile"
     
     #Set Variables if not defined when executing the function
     If ($SendMail -ne $true) { $SendMail = $false }
     If (!$To) { $SendMail = $false }
     If ($SendMail -eq $true) {
        #Set Static Variables
        $From = ""
        $SMTPServer = ''        
        }
     If (!$Threshold) { $Threshold = '80' }
     If (!$SampleInterval) { $SampleInterval = '60' }
     If (!$MaxSamples) { $MaxSamples = '30' }



     #Scan
     $CookedValue = $(Get-Counter -Counter '\Memory\% Committed Bytes In Use' -SampleInterval $SampleInterval -MaxSamples $MaxSamples).CounterSamples.CookedValue
     Foreach ($Value in $CookedValue){ $TotalValue += $Value }
     $Result = $TotalValue / $MaxSamples

     #LogIt
     If ($Result -gt $Threshold) {
        Write-Output '************ERROR LOG************' | Out-File $Log
        Write-Output "Computer: $ENV:COMPUTERNAME" | Out-File $Log -Append
        Write-Output 'Memory: % Committed Bytes in Use' | Out-File $Log -Append
        Write-Output "Threshold: $Threshold" | Out-File $Log -Append
        Write-Output "Scan Interval: Scanned every $SampleInterval seconds.  Completed $MaxSamples scans." | Out-File $Log -Append
        Write-Output "Average % Committed Bytes in Use: $Result" | Out-File $Log -Append
        $LogContent = Get-Content $Log

        If ($SendMail -eq $True) {
            $message = New-Object System.Net.Mail.MailMessage $From, $To
            $message.Subject = "New Alert: Memory Utilization Threshold Reached on $ENV:COMPUTERNAME"
            $message.IsBodyHTML = $true
            $message.Body = $LogContent | ConvertTo-Html 
            $message.Attachments.Add($Log)
            $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
            $smtp.Send($message)
            }

        }
}

Function Monitor-Disk {
 <#
     .SYNOPSIS
     This function scans the server's file system for logical disk usage.  

     .DESCRIPTION
     If parameters are not set otherwise, the scan will trigger alerts if any disk has surpassed 90% utilization.

     .NOTES
     Function Name  : Monitor-Disk 
     Author     : Dave 
     Version    : 1.0

     .PARAMETER Threshold
     This parameter determines what the threshold should be for error reporting.  If a value is not set for this parameter when executing the function, it will default to "90%"

     .PARAMETER SendMail
     This boolean parameter determines whether errors should be reported via email.  It will default to $false unless explicitly set to $true.

     .PARAMETER To
     This parameter defines the send-to address for any error reporting.  If this is not set, the SendMail parameter will revert to $false, regardless of if it was set to $true.

     .EXAMPLE
     Monitor-Disk
     This command will monitor the disk utilization. If it exceeds 90% (since the threshold variable wasn't set), it will log the event.  No email will be sent.

     .EXAMPLE
     Monitor-Disk -Threshold 40 -SendMail $true -to Operations@contoso.com
     This command will monitor the disk utilization.  If it exceeds 40% it will log the event and send an email to Operations@contoso.com.

     #>
      param
     (
         [int]
         $Threshold,

         [bool]
         $SendMail,

         [string]
         $To
     )

     #Set Error Log Path
     if ($(Test-Path C:\PSCode) -eq $false) { New-Item -Path C:\ -Name PSCode -ItemType Directory }
     if ($(Test-Path C:\PSCode\Monitor-Disk) -eq $false) { New-Item -Path C:\PSCode\ -Name Monitor-Disk -ItemType Directory }
     $logpath = 'C:\PSCode\Monitor-Disk\'
     $logfile = "$(Get-Date -UFormat %Y-%m-%d_%H%M)_Monitor-Disk_LOG.txt"
     $log = "$logpath$logfile"
     
     #Set Variables if not defined when executing the function
     If ($SendMail -ne $true) { $SendMail = $false }
     If (!$To) { $SendMail = $false }
     If ($SendMail -eq $true) {
        #Set Static Variables
        $From = ""
        $SMTPServer = ''        
        }
     If (!$Threshold) { $Threshold = '90' }

     #Scan
     $Result = @()
     $Disks = Get-WmiObject -Class win32_logicaldisk | Where-Object { $_.DriveType -eq '3' }
     Foreach ($Disk in $Disks) {
        $Usage = ($Disk.FreeSpace / $Disk.Size) * 100
        if ($Usage -gt $Threshold) {
            $DObject = New-Object psobject
            $DObject | Add-Member -MemberType NoteProperty -Name Disk -Value $Disk.DeviceID
            $DObject | Add-Member -MemberType NoteProperty -Name 'Used' -Value $Usage
            $Result += $DObject
            }
        }
     #LogIt
     If ($Result) { 
        Write-Output '************ERROR LOG************' | Out-File $Log
        Write-Output "Computer: $ENV:COMPUTERNAME" | Out-File $Log -Append
        Write-Output 'Disk Usage Alert' | Out-File $Log -Append
        Write-Output "Alert Threshold: $Threshold" | Out-File $Log -Append
        Write-Output "Disk ID: $($Result.Disk)" | Out-File $Log -Append
        Write-Output "% Used : $($Result.Used)" | Out-File $Log -Append

        $LogContent = Get-Content $Log 

        If ($SendMail -eq $True) {
            $message = New-Object System.Net.Mail.MailMessage $From, $To
            $message.Subject = "New Alert: Memory Utilization Threshold Reached on $ENV:COMPUTERNAME"
            $message.IsBodyHTML = $true
            $message.Body = $LogContent | ConvertTo-Html 
            $message.Attachments.Add($Log)
            $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
            $smtp.Send($message)
            }

        }


}

Function Monitor-Service {
     <#
     .SYNOPSIS
     This function monitors a specific service and logs if it is not in the "Running" state. If the -TakeAction switch is used, it will attempt auto-resolution.  

     .NOTES
     Function Name  : Monitor-Service 
     Author     : Dave 
     Version    : 1.0

     .PARAMETER Service
     This parameter is to identify the specific Service to monitor.  The Service name should be used, not the Description or Common Name. 

     .PARAMETER TakeAction
     This boolean parameter determines whether attempts to start a service that has errrored will be taken.

     .PARAMETER SendMail
     This boolean parameter determines whether errors should be reported via email.  It will default to $false unless explicitly set to $true.

     .PARAMETER To
     This parameter defines the send-to address for any error reporting.  If this is not set, the SendMail parameter will revert to $false, regardless of if it was set to $true.

     .EXAMPLE
     Monitor-Service -Service wuauserv
     This command will monitor the wuauserv service (Windows Update).  No action will be taken to start the service.  No email will be sent.  Errrors will be logged.

     .EXAMPLE
     Monitor-Service -Service wuauserv -TakeAction $true -SendMail $true -to Operations@contoso.com
     This command will monitor the wuauserv service (Windows Update).  Upon errror, action will be taken to attempt to start the service.  An email will be sent to operations@contoso.com and errrors will be logged.

     #>


    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Service,

        [bool]
        $TakeAction,

        [string]
        $SendMail,

        [string]
        $To
    )

     #Set Error Log Path
     if ($(Test-Path C:\PSCode) -eq $false) { New-Item -Path C:\ -Name PSCode -ItemType Directory }
     if ($(Test-Path C:\PSCode\Monitor-Service) -eq $false) { New-Item -Path C:\PSCode\ -Name Monitor-Service -ItemType Directory }
     $logpath = 'C:\PSCode\Monitor-Service\'
     $logfile = "$(Get-Date -UFormat %Y-%m-%d_%H%M)_Monitor-Service_LOG.txt"
     $log = "$logpath$logfile"

     #Set Variables if not defined when executing the function
     If ($SendMail -ne $true) { $SendMail = $false }
     If (!$To) { $SendMail = $false }
     If ($SendMail -eq $true) {
        #Set Static Variables
        $From = ""
        $SMTPServer = ''        
        }
     If ($TakeAction -ne $true) { $TakeAction = $false }

     #Scan & LogIt
     $Scan = Get-Service -Name $Service
     if ($Scan.Status -ne 'Running') {
        Write-Output '************ERROR LOG************' | Out-File $Log
        Write-Output "Computer: $ENV:COMPUTERNAME" | Out-File $Log -Append
        Write-Output "Service: $Service" | Out-File $Log -Append
        Write-Output "Status: $($Scan.Status)" | Out-File $Log -Append
        if ($TakeAction -eq $true) {
            $Scan.Start()
            Write-Output "Action Taken?: $TakeAction" | Out-File $Log -Append
            } else {
            Write-Output "Action Taken?: $TakeAction" | Out-File $Log -Append
            }
     }

     #LogIt
        $LogContent = Get-Content $Log

        If ($SendMail -eq $True) {
            $message = New-Object System.Net.Mail.MailMessage $From, $To
            $message.Subject = "New Alert: Critical Service $($Scan.Status) on $ENV:COMPUTERNAME"
            $message.IsBodyHTML = $true
            $message.Body = $LogContent | ConvertTo-Html 
            $message.Attachments.Add($Log)
            $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
            $smtp.Send($message)
            }
}

Function Monitor-Process {
     <#
     .SYNOPSIS
     This function monitors a specific process and logs if it is not runng. If the -TakeAction switch is used, it will attempt auto-resolution.  

     .NOTES
     Function Name  : Monitor-Process 
     Author     : Dave 
     Version    : 1.0

     .PARAMETER Process
     This parameter is to identify the specific Process to monitor.  The Process name should be used, not the Description or Common Name. 

     .PARAMETER TakeAction
     This boolean parameter determines whether attempts to start a process that has errrored will be taken.

     .PARAMETER SendMail
     This boolean parameter determines whether errors should be reported via email.  It will default to $false unless explicitly set to $true.

     .PARAMETER To
     This parameter defines the send-to address for any error reporting.  If this is not set, the SendMail parameter will revert to $false, regardless of if it was set to $true.

     .EXAMPLE
     Monitor-Process -Proces wuauserv
     This command will monitor the wuauserv service (Windows Update).  No action will be taken to start the service.  No email will be sent.  Errrors will be logged.

     .EXAMPLE
     Monitor-Service -Service wuauserv -TakeAction $true -SendMail $true -to Operations@contoso.com
     This command will monitor the wuauserv service (Windows Update).  Upon errror, action will be taken to attempt to start the service.  An email will be sent to operations@contoso.com and errrors will be logged.

     #>


    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Process,

        [bool]
        $TakeAction,

        [string]
        $SendMail,

        [string]
        $To
    )

     #Set Error Log Path
     if ($(Test-Path C:\PSCode) -eq $false) { New-Item -Path C:\ -Name PSCode -ItemType Directory }
     if ($(Test-Path C:\PSCode\Monitor-Process) -eq $false) { New-Item -Path C:\PSCode\ -Name Monitor-Process -ItemType Directory }
     $logpath = 'C:\PSCode\Monitor-Process\'
     $logfile = "$(Get-Date -UFormat %Y-%m-%d_%H%M)_Monitor-Process_LOG.txt"
     $log = "$logpath$logfile"
     $restartprocess = "restart_$Process.txt"
     if ($(Test-Path "$logpath$restartprocess") -eq $false) {New-Item -Path $logpath -Name $restartprocess -ItemType File}

     #Set Variables if not defined when executing the function
     If ($SendMail -ne $true) { $SendMail = $false }
     If (!$To) { $SendMail = $false }
     If ($SendMail -eq $true) {
        #Set Static Variables
        $From = ""
        $SMTPServer = ''        
        }
     If ($TakeAction -ne $true) { $TakeAction = $false }

     #Scan & LogIt
     $Scan = Get-Process -Name $Process -ErrorAction SilentlyContinue
     if ($Scan) {Write-Output "$($Scan.Path)" | Out-File $logpath$restartprocess}
        else {
            Write-Output '************ERROR LOG************' | Out-File $Log
            Write-Output "Computer: $ENV:COMPUTERNAME" | Out-File $Log -Append
            Write-Output "Process: $Process" | Out-File $Log -Append
            Write-Output "Status: $Process not running" | Out-File $Log -Append
            if ($TakeAction -eq $true) {
                Start-Process -FilePath $(Get-Content -Path "$logpath$restartprocess")
                Write-Output "Action Taken?: $TakeAction" | Out-File $Log -Append
                } else {
                Write-Output "Action Taken?: $TakeAction" | Out-File $Log -Append
                }
         }

     #LogIt
        If ($SendMail -eq $True) {
            $LogContent = Get-Content $Log
            $message = New-Object System.Net.Mail.MailMessage $From, $To
            $message.Subject = "New Alert: Critical Service $($Scan.Status) on $ENV:COMPUTERNAME"
            $message.IsBodyHTML = $true
            $message.Body = $LogContent | ConvertTo-Html 
            $message.Attachments.Add($Log)
            $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
            $smtp.Send($message)
            }
}

Function Monitor-WebSite {}