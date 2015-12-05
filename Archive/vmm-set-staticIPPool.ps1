$Hostname = Read-Host "Hostname"
get-scvirtualmachine $Hostname | get-scvirtualnetworkadapter | set-scvirtualnetworkadapter -IPv4AddressType Static