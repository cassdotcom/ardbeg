Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
$xamlFile = "C:\Users\ac00418\Documents\ardbeg\forms\formCensus.xaml"
#. C:\Users\ac00418\Documents\ardbeg\ardbeg-master\db\census\Get-CensusData.ps1

$syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)      
    
$psCmd = [PowerShell]::Create().AddScript({   
    [xml]$xaml = [xml](Get-Content "C:\Users\ac00418\Documents\ardbeg\forms\formCensus.xaml")

    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $syncHash.TextBox = $syncHash.window.FindName("tbA")
    $syncHash.ComboBox = $syncHash.window.FindName("cbA")
    $syncHash.ButtonA = $syncHash.window.FindName("btA")
    $syncHash.LabelA = $syncHash.window.FindName("laA")
    $syncHash.StatusBar = $syncHash.window.FindName("sbA")
    $syncHash.RichTextBox = $syncHash.window.FindName("rtbA")

    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error


})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()
