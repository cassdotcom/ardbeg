function Send-OutlookMessage
{

    Param(
        [System.String]
        $emailTo,
        [System.String]
        $emailSubject,
        [System.String]
        $emailBody
    )

    $ol = New-Object -ComObject outlook.application
    $mail = $ol.CreateItem(0)

    $mail.Recipients.Add($emailTo)
    $mail.Subject = $emailSubject
    $mail.Body = $emailBody

    $mail.Send()

}

