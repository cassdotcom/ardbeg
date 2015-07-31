function Update-Window {
    Param (
        $content,
        [Switch]$AppendContent=$null
    )
    $syncHash.textbox.Dispatcher.invoke("Normal",[action]{
		if ($AppendContent) { 
            $syncHash.textbox.SelectAll()
            $syncHash.tsel = $syncHash.TextBox.Selection
            $syncHash.TextBox.Selection.Text = "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss"):`t"
		} else {
			$syncHash.TextBox.AppendText("$($content)")
		}
    }
    )
	
}

function Update-ComboBox {

	Param (
		[Switch]$GetValue,
		[Switch]$GetIndex,
		[Switch]$GetItem
	)
	
	$syncHash.ComboBox.Dispatcher.invoke([action]{
      
        $syncHash.ind = $syncHash.ComboBox.SelectedIndex
        $syncHash.num = $syncHash.ComboBox.SelectedValue
        $syncHash.ite = $syncHash.ComboBox.SelectedItem
		
    },
    "Normal")
	
}


Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
$syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash) 

$psCmd = [PowerShell]::Create().AddScript({   
    [xml]$xaml = @"
<Window x:Name="formMain"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="MainWindow" Height="488" Width="684"
    WindowStartupLocation = "CenterScreen"
    ShowInTaskbar = "True">
    <Grid>
    	<Grid.ColumnDefinitions>
    		<ColumnDefinition Width="295*"/>
    		<ColumnDefinition Width="381*"/>
    	</Grid.ColumnDefinitions>
    	<ComboBox Name="comboboxNetworks" HorizontalAlignment="Left" Margin="35,40,0,0" VerticalAlignment="Top" RenderTransformOrigin="-1.241,-1.506" Height="30" Width="120" BorderBrush="#FFB93434" Background="White" BorderThickness="3"/>
    	<Button Name="btCombo" Content="Button" HorizontalAlignment="Left" Margin="175,40,0,0" VerticalAlignment="Top" Width="30" RenderTransformOrigin="0,-0.493" Height="30"/>
    	<RichTextBox Name="rtbMain" HorizontalAlignment="Left" Height="330" Margin="35,90,0,0" VerticalAlignment="Top" Width="460" RenderTransformOrigin="0.45,0.5" Grid.ColumnSpan="2">
    		<FlowDocument>
    			<Paragraph></Paragraph>
    		</FlowDocument>
    	</RichTextBox>        
    </Grid>
</Window>
"@
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $syncHash.TextBox = $syncHash.window.FindName("rtbMain")
    $syncHash.ComboBox = $syncHash.window.FindName("comboboxNetworks")
    $syncHash.btCombo = $syncHash.window.FindName("btCombo")
	
	#region NET_NUMBERS
	$list = gc "C:\Users\ac00418\Documents\ardbeg\ardbeg-master\db\NETWORKS_NUMBERS.txt"

    $syncHash.ComboBox.Dispatcher.invoke([action]{
        
        foreach ( $n in $list ) { $syncHash.ComboBox.Items.Add($n) | Out-Null }

    },
	"Normal")
	#endregion NET_NUMBERS
	
	$syncHash.textbox.Dispatcher.invoke([action]{
		
		$syncHash.TextBox.AppendText("WELCOME TO MIAMI")

	},
	"Normal")
	
	

    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
	
})

$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()


