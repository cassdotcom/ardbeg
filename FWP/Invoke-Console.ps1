# Do events work with Gui objects
import-module WPFRunspace
 

$Global:x = [Hashtable]::Synchronized(@{})
$Global:x.Host = $Host






[ScriptBlock]$cmd = { 
import-module WPFRunspace
add-WpfAccelerators 
# Not that to write to the host must use $x.Host otherwise will block
#write-host "This will cause blocking"  
$x.Host.UI.WriteLine("Start Script") #

$xaml = @" 
<Window
                xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                Title="MainWindow" Height="450" Width="600">
            <Grid>
                <Button Name="test" Content="Search" HorizontalAlignment="Left" Margin="0,10,0,0" VerticalAlignment="Top" Width="319" Height="35" Background="#FF4694D4" BorderBrush="#FF4694D4" BorderThickness="0"/>
                <ListBox Name="listBox" HorizontalAlignment="Left" Height="250" Margin="10,74,10,0" VerticalAlignment="Top" Width="250" AllowDrop="True" SelectionMode="Extended" />
                <TextBox Name="textBox" HorizontalAlignment="Left" Height="50" Margin="270,74,10,0" VerticalAlignment="Top" Width="300" />
            </Grid>
        </Window>
"@



[scriptblock]$script = {
"Script started."
"This is a long running script and will take 20 seconds."
Start-Sleep -Seconds 20
"script completed."
}


#Handler script for DataReady event

[scriptblock]$dataReady = {

      $text = $Script:Worker.GetReadyData()
      $x.Host.UI.WriteLine($text)
      $listBox.Items.Add($text)
      
}

[scriptblock]$stateChanged = {
      
     if ($Script:Worker.StateInfo.State -gt [PipelineState]::Stopping)
     {  
      
      $x.Host.UI.WriteLine( "State Changed Job completed")
      $listBox.Items.Add("The text you added was:")
      $listBox.Items.Add($textBox.Text)
    
      }

      
}

$window = [Window][System.Windows.Markup.XamlReader]::Parse($xaml)
[ListBox]$listBox = $window.FindName("listBox")
 [TextBox]$textBox = $window.FindName("textBox")
 $textBox.Text = "Enter text while waiting for completion of script"

# Script block to respond to button click
[scriptblock]$btnTestClick = { 
$x.Host.UI.WriteLine("Button Clicked - call background worker " )
$listBox.Items.Add('Button Clicked')
[BackgroundWorker]$Script:Worker = New-WPFBackgroundWorker -ScriptBlock $script -FrameworkElement $window -DataReadyAction $dataReady  -StateChangedAction $stateChanged  #-Parameters $parameters
#Start the backgroundworker
$Script:Worker.Invoke()
}
 
 
 [Button]$btnTest = $window.FindName("test")
 $btnTest.Add_Click($btnTestClick)
 $window.ShowDialog()
}

# An array of parameters
$parameters = ([PSHelper]::NewPSParameter("x",$x))


$bgworker = New-WPFBackgroundWorker -ScriptBlock $cmd -Parameters $parameters

# Can also use 
# $bgworker = [PSHelper]::CreateBGWorker()
# $bgworker.ScriptBlock = $cmd 
#$bgworker.Parameters = $parameters
 $bgworker.Invoke() 
 
