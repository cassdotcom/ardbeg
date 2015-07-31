function sendMail
{
Param(
    [System.Management.Automation.CredentialAttribute()]
    $myCred,
    [System.String]
    $emailSubject,
    [System.String]
    $emailBody
)

Send-MailMessage -From tourmalet_sysops@outlook.com -Subject $emailSubject -To cassdotcom@gmail.com -Body $emailBody -Credential $myCred -DeliveryNotificationOption OnSuccess,OnFailure,Delay -Port 25 -SmtpServer smtp-mail.outlook.com -UseSsl
}