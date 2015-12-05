#Function to export credential to encrypted file
#Edited to include $CredName parameter.  This will allow multiple different Credentials to be used.

try {$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)} catch{}
if (-not(test-path variable:\ScriptPath -ErrorAction SilentlyContinue)) {$ScriptPath = '.\'}
function Export-PSCredential {
	param ( $Credential = (Get-Credential), $CredName, $Credfile = $ScriptPath + "\$CredName.enc.xml")

	# Look at the object type of the $Credential parameter to determine how to handle it
	switch ( $Credential.GetType().Name ) {
		# It is a credential, so continue
		PSCredential		{ continue }
		# It is a string, so use that as the username and prompt for the password
		String				{ $Credential = Get-Credential -credential $Credential }
		# In all other caess, throw an error and exit
		default				{ Throw "You must specify a credential object to export to disk." }
	}
	
	# Create temporary object to be serialized to disk
	$export = "" | Select-Object Username, EncryptedPassword
	
	# Give object a type name which can be identified later
	$export.PSObject.TypeNames.Insert(0,'ExportedPSCredential')
	
	$export.Username = $Credential.Username
	

	# Encrypt SecureString password using Data Protection API
	# Only the current user account can decrypt this cipher
	$export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString

	# Export using the Export-Clixml cmdlet
	$export | Export-Clixml $Credfile
	Write-Host -foregroundcolor Green "Credentials saved to: " -noNewLine

	# Return FileInfo object referring to saved credentials
	Get-Item $Credfile
}
