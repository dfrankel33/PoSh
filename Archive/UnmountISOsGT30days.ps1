$date = get-date
$30days = $date.AddDays(-30)
$ISOVMs = get-scvirtualmachine -All | get-scvirtualdvddrive | where {$_.Connection -ne 'None'}

foreach ($ISOVM in $ISOVMs) {
    If ($ISOVM.AddedTime -lt $30days) {
    $ISOVM | Set-SCVirtualDVDDrive -NoMedia
    }

}