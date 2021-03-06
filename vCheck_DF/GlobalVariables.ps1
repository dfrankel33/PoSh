#Data Edited from GlobalVariables.ps1 script
#$virtualhosts=import-csv "C:\vcheck_df\test_df.csv"
$outputpath = "c:\vcheck_df\Output_DF\"
$ScriptPath = "C:\vcheck_df\"
#$credfile = $ScriptPath + "Windowscreds.enc.xml"


#DF edit
#foreach ($virtualhost in $virtualhosts)
 #   {
    # You can change the following defaults by altering the below settings:
    #

    # Set the following to true to enable the setup wizard for first time run
    $SetupWizard = $False

    # DF edit
    #If ($VirtualHosts.Credential -eq $Null) {$Credfile = "C:\Vcheck_DF\Default.enc.xml"}
    #Else {$Credfile = $VirtualHosts.Credential}
    #$Credfile = $VirtualHost.Credential

    # Start of Settings
    # Please Specify the address (and optional port) of the server to connect to [servername(:port)]
    #DF Edit - This is now defined in the foreach loop on the top-level script
    #$Server = $virtualhost.ESX
    # Would you like the report displayed in the local browser once completed ?
    $DisplaytoScreen = $false
    # Use the following item to define if an email report should be sent once completed
    $SendEmail = $true
    # Please Specify the SMTP server address (and optional port) [servername(:port)]
    $SMTPSRV = "SMTP.Smiths.com"
    # Would you like to use SSL to send email?
    $EmailSSL = $true
    # Please specify the email address who will send the vCheck report
    $EmailFrom = "vCheck_Scan@smiths.com"
    # Please specify the email address(es) who will receive the vCheck report (separate multiple addresses with comma)
    #DF Edit - This is now defined in the foreach loop on the top-level script
    #$EmailTo = $virtualhost.Admin
    # Please specify the email address(es) who will be CCd to receive the vCheck report (separate multiple addresses with comma)
    #This is now defined in the foreach loop on the top-level script
    #$EmailCc = ""
    # Please specify an email subject 
    $EmailSubject = "$Server vCheck Report"
    # Send the report by e-mail even if it is empty?
    $EmailReportEvenIfEmpty = $false
    # If you would prefer the HTML file as an attachment then enable the following:
    $SendAttachment = $true
    # Set the style template to use.
    $Style = "CleanGreen"
    # Set the following setting to $true to see how long each Plugin takes to run as part of the report
    $TimeToRun = $false
    # Report an plugins that take longer than the following amount of seconds
    $PluginSeconds = 30
    # End of Settings

    # End of Global Variables
#   }