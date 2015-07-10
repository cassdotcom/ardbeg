Param(
    [System.Management.Automation.CredentialAttribute()]
    $myCred
)

try {

<#
$md = Get-FileMetaData -folder (gci "C:\Users\cass\Music\FLAC" -Recurse -Directory).FullName
$md_dets = @"
Count = $($md.count) @ $(Get-Date -Format "HH:mm:ss")
"@

sendMail -myCred $myCred -emailSubject "Scanned FLAC" -emailBody $md_dets




$md | Export-Csv -Path "C:\repo\ardbeg\FLAC_metadata.csv" -NoTypeInformation

sendMail -myCred $myCred -emailSubject "Export FLAC" -emailBody "Export FLAC"


#>


$mdmp = Get-FileMetaData -folder (gci "C:\Users\cass\Music\iTunes\iTunes Media\Music\" -Recurse -directory).FullName
$mp_dets = @"
MP3 Count = $($mdmp.count) @ $(Get-Date -Format "HH:mm:ss")
"@

sendMail -myCred $myCred -emailSubject "Scanned iTunes" -emailBody $mp_dets






$mdmp | Export-Csv -Path "C:\repo\ardbeg\iTunes_metadata.csv" -NoTypeInformation

sendMail -myCred $myCred -emailSubject "Exported iTunes" -emailBody "Exported mp3"

Start-Sleep 120

sendMail -myCred $myCred -emailSubject "FINISHED" -emailBody "all done"

} catch {

$error_dets = @"
ERROR:
$_
"@

sendMail -myCred $myCred -emailSubject "ERROR" -emailBody $error_dets

}

