# ************************************************************************

#

# Script Name: .\Invoke-WpfWorkerExample.ps1

# Version: 1.0.0.0

# Author: Pianoboy

# Date: 14/12/2014

#Description: An example of how to use WPFRunspace.BackgroundWorker in WPF script.

#************************************************************************

#Only require this if using Powershell 2.0
import-module WPFRunspace

# Add accelerators for wpf (if you don't wish to use fully qualified paths).
# To prevent name conflicts you can use the -Prefix switch that will add 'Wpf.' prefix to accelerator.
add-WpfAccelerators 


$xaml=@"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Background Worker Example" Height="550" Width="650">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition MaxHeight="50" />
            <RowDefinition MaxHeight="35" />
            <RowDefinition MaxHeight="50" />
            <RowDefinition MaxHeight="35" />
            <RowDefinition x:Name="lastRow" Height="*"/>
            <RowDefinition  MaxHeight="30"/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="1*"/>
            <ColumnDefinition Width="1*"/>
        </Grid.ColumnDefinitions>
        <StackPanel Orientation="Horizontal" Margin="5" Grid.Row="0" Grid.Column="0">
        <Button x:Name="btnRun" Margin="5" Content="Run Script"/>
        <Button x:Name="btnCancel" Margin="5" Padding="5" Content="Cancel Script"/>
        <Button x:Name="btnView" Margin="5" Padding="5" Content="View The Code"/>
        </StackPanel>
        <StackPanel Orientation="Horizontal" Margin="5" Grid.Row="1" Grid.ColumnSpan="2">
        <Label  Content="Start:" HorizontalContentAlignment="Right" VerticalContentAlignment="Center"/>
        <TextBox x:Name="txtStart" Text="1000" VerticalContentAlignment="Center"/>
       <Label  Content="End:" HorizontalContentAlignment="Right" VerticalContentAlignment="Center"/>
        <TextBox x:Name="txtEnd" Text="1010" VerticalContentAlignment="Center"/>
        <Label  Content="Sleep(Milliseconds):" HorizontalContentAlignment="Right" VerticalContentAlignment="Center"/>
        <TextBox x:Name="txtSleep" Text="1000" VerticalContentAlignment="Center"/>
        </StackPanel>
        <TextBox x:Name="txtEnter" Grid.Row="2" Background="AliceBlue" Grid.ColumnSpan="2">Enter some text while waiting.</TextBox>
        <Label Grid.Row="3" Grid.Column="0" VerticalContentAlignment="Bottom">DataReady Script Results:</Label>
        <Label Grid.Row="3" Grid.Column="1" VerticalContentAlignment="Bottom">StateChanged Script Results:</Label>
        
        <TextBox  x:Name="txtDataReady" 
                  Grid.Row="4" Grid.Column="0"
                  Background="AliceBlue"
            TextWrapping="Wrap"
            AcceptsReturn="True"
            Height="{Binding ElementName=lastRow, Path=Height}"
            VerticalAlignment="Stretch"
            IsReadOnly="True"      
            MaxLines="25"
            VerticalScrollBarVisibility="Visible"
             ></TextBox>
<TextBox  x:Name="txtStateChanged" 
                  Grid.Row="4" Grid.Column="1"
                  Background="Ivory"
            TextWrapping="Wrap"
            AcceptsReturn="True"
            Height="{Binding ElementName=lastRow, Path=Height}"
            VerticalAlignment="Stretch"
            IsReadOnly="True"      
            MaxLines="25"
            VerticalScrollBarVisibility="Visible"
             ></TextBox>
       <StatusBar Grid.Row="5" Grid.ColumnSpan="2" MaxHeight="25" HorizontalContentAlignment="Left" VerticalContentAlignment="Center">
       <StackPanel Orientation="Horizontal">
            <TextBlock x:Name="txtStatus" VerticalAlignment="Top" >State: Not Started</TextBlock>
            <ProgressBar  x:Name="progressBar" MaxHeight="25" Margin="5,2,2,2" Width="50" Visibility="Collapsed"></ProgressBar>
        </StackPanel>
        </StatusBar> 
    </Grid>
</Window>


"@



[scriptblock]$script = {
#Try changing millisecinds to 10 no collisions?
# Get-content is added to demonstrate error in script
($start..$end) | Select-Object @{Name="Value";E={$_}},@{Name="Sqrt";"E"={[Math]::Sqrt($_)}} | 
foreach { $_ ;start-sleep -Milliseconds $sleep}
get-content -Path d:\I_DoNot_Exist.txt
}


#Handler script for DataReady event
$dataReady = {
   # Get last item added to ready queue
   $lastItem = $Script:drWorker.GetReadyData()
   $script:count++ #This variable is for the progress bar
   if ($lastItem -ne $null -and $Script:drWorker.Errors.Count-eq 0)
   {
    if ($script:count -eq 5)
    {
       # What happens if error in handler script?
       write-error -Message "Really big example error here" -ErrorAction Continue
       #what happens if we now change action
       #$script:drWorker.DataReadyAction = {[system.windows.forms.MessageBox]::Show("Don't do this")}

       # Can output to console
       write-host "Test writing to console"
    }
    $txtDataReady.Text += "Value: $($lastItem.Value) Square Root: $($lastItem.Sqrt)`n" 
   }
  
  $progressBar.Value = $Script:count/($script:end-$script:start + 1) * 100 # Update progress
}


#Handler script for StateChanged 
$stateChanged = {
   
  
   $txtStatus.Text = "State: $($Script:drWorker.StateInfo.State)"
   # Completed,Stopped and Failed have higher enum value than stopping
   # When pipeline stops it will either be Stopped,Failed or Completed
   # In this example it does not matter which of the three state changes have
   # occurred as we simply output the results acheived to that point.
   # In other cases you may need to add your own clean-up code for the different states.
   if ($Script:drWorker.StateInfo.State -gt [PipelineState]::Stopping)
   {
        if ($Script:drWorker.Results.Count -gt 0)
        {
            $txtStateChanged.Text +="`nResults: $($Script:drWorker.Results.Count) Of Type: $($Script:drWorker.Results.GetTYpe())`n"
            foreach ($result in $Script:drWorker.Results)
            {
                 $txtStateChanged.Text += "Value: $($result.Value) Square Root: $($result.Sqrt)`n"
            }  
            
           
         } 
           
           
           $txtStateChanged.Text += "`nError Count: $($Script:drWorker.Errors.Count)"
           if ($Script:drWorker.Errors.Count -gt 0)
           {
                 foreach ($err in $Script:drWorker.Errors)
                 {
                    $txtStateChanged.Text += "`n$($err.Exception.Message)"
                 }
           }

           $txtStateChanged.Text += "`n`nThe text you entered:`n"
           $txtStateChanged.Text += $txtEnter.Text

            $btnRun.IsEnabled = $true # enable the button
    }
    
}

# Scriptblock to stop running backgroundworker
[scriptblock]$btnCancelClick = { 
 # simply call stop on the backgroundworker to stop the pipeline.
 # Once stop is called the statechanged event will change from running to stopping to stopped.
 # You can add any cleanup code to your statechanged handler.
 $script:drWorker.Stop()
 $txtDataReady.Text += "Script has been cancelled."

}

#View this code
[scriptblock]$btnViewClick = { 
 
  powershell_ise   "$PSScriptRoot\Invoke-WpfWorkerExample.ps1"
 
}



# Script block to respond to button click
[scriptblock]$btnRunClick = { 
 $btnRun.IsEnabled = $false #disable the button
 $txtStateChanged.Clear()  
 $txtDataReady.Clear()
 $script:count = 0
 

# These variables are at script level as they need to be used in handler script
$script:start = [int]::Parse($txtStart.Text)
$script:end = [int]::Parse($txtEnd.Text)
$script:sleep = [int]::Parse($txtSleep.Text)

# Use PSHelper NewPSParameter function to add any parameters
$parameters = ([PSHelper]::NewPSParameter("start",$script:start),
                [PSHelper]::NewPSParameter("end",$script:end),[PSHelper]::NewPSParameter("sleep",$script:sleep))


# Now create backgroundworker 
$Script:drWorker = New-WPFBackgroundWorker -ScriptBlock $script -FrameworkElement $window -DataReadyAction $dataReady -StateChangedAction $stateChanged -Parameters $parameters
$progressBar.Visibility="Visible"
$progressBar.Value=0


#Start the backgroundworker
$Script:drWorker | Invoke-WPFBackgroundWorker 
}




# Here we create and set up the window
 $window = [System.Windows.Window][System.Windows.Markup.XamlReader]::Parse($xaml)
 [Button]$btnRun = $window.FindName("btnRun")
 $btnRun.Add_Click($btnRunClick)
 [Button]$btnCancel = $window.FindName("btnCancel")
 $btnCancel.Add_Click($btnCancelClick)
 [Button]$btnView = $window.FindName("btnView")
 $btnView.Add_Click($btnViewClick)
 [TextBox]$txtDataReady = $window.FindName("txtDataReady")

 [TextBox]$txtStateChanged = $window.FindName("txtStateChanged")

 [TextBox]$txtEnter = $window.FindName("txtEnter")
 [TextBlock]$txtStatus = $window.FindName("txtStatus")
 [TextBox]$txtStart = $window.FindName("txtStart")
 [TextBox]$txtEnd = $window.FindName("txtEnd")
 [TextBox]$txtSleep = $window.FindName("txtSleep")
 [ProgressBar]$progressBar = $window.FindName("progressBar")

 $window.ShowDialog() | out-null
