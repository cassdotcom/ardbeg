function update-Form {

    Param( [int]$num )

    $backJob = {Get-Content "C:\Users\ac00418\Documents\ardbeg\ardbeg-master\db\NETWORKS_NUMBERS.txt";Write-Host "in update"}
    Start-Job -Name backJob -ScriptBlock $backJob -ArgumentList $num
    Wait-Job -Name backJob
    $syncHash.Val = (Receive-Job -Name backJob)[$num]
    $syncHash.textbox.dispatcher.invoke("Normal",[action]{
        if ( $syncHash.Val ) {
            $syncHash.textbox.text = $syncHash.Val
        } else {
            $syncHash.textbox.text = "UNKNOWN"
        }
    })
    Remove-Job -Name backJob
}

function Update-Colour {

    Param(
        [string]$colInput
    )

    Write-Host "in colour"

    if ( ! ($colInput ) ) {
        $col = $syncHash.Coli[$syncHash.ColNum]
        $syncHash.ColNum++
        if ( $syncHash.ColNum -eq 5 ) {
            $syncHash.ColNum = 1
        }
    } else {
        $col = $colInput
    }
        
    $syncHash.RichTextBox.Dispatcher.Invoke("normal",[action]{$syncHash.RichTextBox.Background = $col})

}


Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
##$xamlFile = "C:\Users\ac00418\Documents\ardbeg\forms\Window2.xaml"
#. C:\Users\ac00418\Documents\ardbeg\ardbeg-master\db\census\Get-CensusData.ps1

$syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)      
    
$psCmd = [PowerShell]::Create().AddScript({   
    [xml]$xaml = [xml](Get-Content "C:\Users\ac00418\Documents\ardbeg\forms\Window2.xaml")

    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $syncHash.TextBox = $syncHash.window.FindName("tbName")
    $syncHash.ComboBox = $syncHash.window.FindName("cbName")
    $syncHash.ButtonA = $syncHash.window.FindName("btTBName")
    $syncHash.LabelA = $syncHash.window.FindName("lbTitle")
    $syncHash.StatusBar = $syncHash.window.FindName("sbStatus")
    $syncHash.RichTextBox = $syncHash.window.FindName("rtbResults")

    $syncHash.Coli = @{1='Red';2='Blue';3='Black';4='Green'}
    $syncHash.ColNum = 1

    $syncHash.func = {update-Form}
    $syncHash.ButtonA.add_Click({$syncHash.func})

    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error


})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()
