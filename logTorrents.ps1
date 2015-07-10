
Param(
    [Parameter(Mandatory=$true)]
    [System.String]
    $torrentPath,
    [Parameter(Mandatory=$true)]
    [System.String]
    $torrentName
)





    Try
    {
        $logFile = "C:\Users\cass\Downloads\torr_logs.txt"
$msg = @"
$(Get-Date -Format "yyyy-MM-dd`tHH-mm-ss)
$(Get-Date -Format "yyyy-MM-dd`tHH-mm-ss)`t$($torrentName)
$(Get-Date -Format "yyyy-MM-dd`tHH-mm-ss)`t$($torrentPath)
"@

        $msg | Out-File $logFile -Append

    } Catch {
        
        break

    }



