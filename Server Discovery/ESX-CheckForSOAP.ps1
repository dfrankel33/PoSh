 # External assembly load declaration 
param (
    [sting]$hostname
    )

function add-assembly($name) 
{ 
return [System.Reflection.Assembly]::LoadWithPartialName($name) 
} 
#set-alias aasm add-assembly 
Add-Assembly System.Windows.Forms 
$oIE=new-object -com internetexplorer.application 
$oIE.visible=$true  
while ($oIE.busy) { 
sleep -milliseconds 50 
} 
$oIE.navigate2("https://$hostname/sdk/vimService?wsdl") 
while ($oIE.busy) { 
sleep -milliseconds 50 
} 
sleep -milliseconds 500 
$doc = $oIE.document 
$textbox = $doc.getElementByID("q") 

# NEW NEW NEW
[xml]$XML = (New-Object System.Net.WebClient).DownloadString("https://$hostname/sdk/vimService?wsdl")

if ($xml.definitions.xmlns -eq "http://scliemas.xmlsoap.org/wsdl/") {write-output "Target server offers ESXi SOAP service!"} 

