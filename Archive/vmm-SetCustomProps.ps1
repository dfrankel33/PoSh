param (
    [string]$hostnameprefix,
    [string]$backup,
    [string]$DR

    )
$ADVMs = get-scvirtualmachine | where {$_.Name -clike "$hostnameprefix*"} #| select Name

foreach ($ADVM in $ADVMs){
    $BackupProp = Get-SCCustomProperty -Name "Backup"
    $BackupValue = Get-SCCustomPropertyValue -InputObject $ADVM -CustomProperty $BackupProp
        if ($BackupValue -eq $null){
        Set-SCCustomPropertyValue -InputObject $ADVM -CustomProperty $BackupProp -Value $Backup
        }

    $DRProp = Get-SCCustomProperty -Name "DR_Service_Level"
    $DRValue = Get-SCCustomPropertyValue -InputObject $ADVM -CustomProperty $DRProp
        if ($DRValue -eq $null){
        Set-SCCustomPropertyValue -InputObject $ADVM -CustomProperty $DRProp -Value $DR
        }

}