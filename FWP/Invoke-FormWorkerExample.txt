# ************************************************************************

#

# Script Name: .\Invoke-FormWorkerExample.ps1

# Version: 1.0.0.0

# Author: Pianoboy

# Date: 14/12/2014

#Description: An example of how to use WPFRunspace.BackgroundWorker in Win Forms script.

#************************************************************************

#Only require this if using Powershell 2.0
import-module WPFRunspace
# Add accelerators for wpf (if you don't wish to use fully qualified paths).
# To prevent name conflicts you can use the -Prefix switch that will add 'Frm.' prefix to accelerator.
Add-WinFormsAccelerators -Prefix


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
      # $script:drWorker.DataReadyAction = {[system.windows.forms.MessageBox]::Show("Don't do this")}
       # Can output to console
       write-host "Test writing to console"
    }
    $txtDataReady.Text += "Value: $($lastItem.Value) Square Root: $($lastItem.Sqrt)" + [System.Environment]::NewLine 
   }
  
  $progressBar.Value = $script:Count/($Script:end - $script:start + 1) * 100
}


#Handler script for StateChanged 
$stateChanged = {
   
  
   $statusLabel.Text = "State: $($Script:drWorker.StateInfo.State)"
   # Completed,Stopped and Failed have higher enum value than stopping
   # When pipeline stops it will either be Stopped,Failed or Completed
   # In this example it does not matter which of the three state changes have
   # occurred as we simply output the results acheived to that point.
   # In other cases you may need to add your own clean-up code for the different states.
   if ($Script:drWorker.StateInfo.State -gt [PipelineState]::Stopping)
   {
        if ($Script:drWorker.Results.Count -gt 0)
        {
            $txtStateChanged.Text += [System.Environment]::NewLine + "Results: $($Script:drWorker.Results.Count) Of Type: $($Script:drWorker.Results.GetTYpe())" + [System.Environment]::NewLine 
            foreach ($result in $Script:drWorker.Results)
            {
                 $txtStateChanged.Text += "Value: $($result.Value) Square Root: $($result.Sqrt)" + [System.Environment]::NewLine
            }  
            
           
         } 
           
           
           $txtStateChanged.Text += [System.Environment]::NewLine + "Error Count: $($Script:drWorker.Errors.Count)"
           if ($Script:drWorker.Errors.Count -gt 0)
           {
                 foreach ($err in $Script:drWorker.Errors)
                 {
                    $txtStateChanged.Text +=  [System.Environment]::NewLine + "$($err.Exception.Message)"
                 }
           }

           $txtStateChanged.Text += [System.Environment]::NewLine + [System.Environment]::NewLine + "The text you entered:" + [System.Environment]::NewLine
           $txtStateChanged.Text += $txtEnter.Text

            $btnRun.Enabled = $true # enable the button
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
 
  powershell_ise   "$PSScriptRoot\Invoke-FormWorkerExample.ps1"
 
}



# Script block to respond to button click
[scriptblock]$btnRunClick = { 
$txtDataReady.Clear()
$txtStateChanged.Clear()
$script:count = 0
# These variables are at script level as they need to be used in handler script
$script:start = [int]::Parse($txtStart.Text)
$script:end = [int]::Parse($txtEnd.Text)
$script:sleep = [int]::Parse($txtSleep.Text)
# Use PSHelper NewPSParameter function to add any parameters
$parameters = ([PSHelper]::NewPSParameter("start",$script:start),
                [PSHelper]::NewPSParameter("end",$script:end),[PSHelper]::NewPSParameter("sleep",$script:sleep))

$Script:drWorker = New-WPFBackgroundWorker -ScriptBlock $script -Control $form -DataReadyAction $dataReady -Parameters $parameters -StateChangedAction $stateChanged
$progressBar.Visible= $true
$btnRun.Enabled = $false #disable the button
$Script:drWorker.Invoke()
  
}





# Here we create and set up the window
 $form = new-object Frm.Form
 $form.Text = "Forms Background Worker Example"
 $form.Width = 650
 $form.Height = 550
 $btnRun = new-object Frm.Button
 $btnRun.Text = "Run Script"
 $btnRun.Left = 10
 $btnRun.Top = 10
 $btnCancel = new-object Frm.Button
 $btnCancel.Text = "Cancel Script"
 $btnCancel.Width = 100
 $btnCancel.Left = $btnRun.Right + 5
 $btnCancel.Top = $btnRun.Top

 $btnView = new-object Frm.Button
 $btnView.Text = "View Code"
 $btnView.Width = 100
 $btnView.Left = $btnCancel.Right + 5
 $btnView.Top = $btnRun.Top


 [Frm.label]$lblStart = new-object Frm.Label
 $lblStart.Text = "Start:"
 $lblStart.Width = 40
 $lblStart.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
 $lblStart.Top = $btnRun.Bottom + 10

 
 
 [Frm.TextBox]$txtStart = new-object Frm.TextBox
 $txtStart.Text = "1000"
 $txtStart.Width = 40
 $txtStart.Left = $lblStart.Right + 5
 $txtStart.Top = $btnRun.Bottom + 10

 [Frm.label]$lblEnd = new-object Frm.Label
 $lblEnd.Text = "End:"
 $lblEnd.Width = 40
 $lblEnd.Left = $txtStart.Right + 5
 $lblEnd.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
 $lblEnd.Top = $btnRun.Bottom + 10

 [Frm.TextBox]$txtEnd = new-object Frm.TextBox
 $txtEnd.Text = "1010"
 $txtEnd.Width = 40
 $txtEnd.Left = $lblEnd.Right + 5
 $txtEnd.Top = $btnRun.Bottom + 10

 [Frm.label]$lblSleep = new-object Frm.Label
 $lblSleep.Text = "Sleep(Milliseconds):"
 $lblSleep.Width = 120
 $lblSleep.Left = $txtEnd.Right + 5
 $lblSleep.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
 $lblSleep.Top = $btnRun.Bottom + 10

 [Frm.TextBox]$txtSleep = new-object Frm.TextBox
 $txtSleep.Text = "1000"
 $txtSleep.Width = 40
 $txtSleep.Left = $lblSleep.Right + 5
 $txtSleep.Top = $btnRun.Bottom + 10

 [Frm.TextBox]$txtEnter = new-object Frm.TextBox
 $txtEnter.MultiLine = $true
 $txtEnter.Text = "Enter some text while waiting."
 $txtEnter.Top = $lblStart.Bottom  + 5
 $txtEnter.Height = 95
 $txtEnter.Width = $form.Width-20


 
 [Frm.TextBox]$txtDataReady = new-object Frm.TextBox
 $txtDataReady.MultiLine = $true
 $txtDataReady.ScrollBars = [Frm.ScrollBars]::Both
 $txtDataReady.Dock = [Frm.DockStyle]::Fill
 $txtDataReady.BackColor = "PowderBlue"

 [Frm.TextBox]$txtStateChanged = new-object Frm.TextBox
 $txtStateChanged.MultiLine = $true
 $txtStateChanged.ScrollBars = [Frm.ScrollBars]::Both
 $txtStateChanged.Dock = [Frm.DockStyle]::Fill
 $txtStateChanged.BackColor = "Ivory"
 
 


 [Frm.label]$lblDataReady = new-object Frm.Label
 $lblDataReady.Text = "Data Ready Script Results:"
 $lblDataReady.Width = 150
 $lblDataReady.Dock = [Frm.DockStyle]::Left

 [Frm.label]$lblStateChanged = new-object Frm.Label
 $lblStateChanged.Text = "State Changed Script Results:"
 $lblStateChanged.Width = 200
 $lblStateChanged.Dock = [Frm.DockStyle]::Left
 
 
 [Frm.StatusStrip]$statusBar = new-object Frm.StatusStrip
 $statusLabel = new-object Frm.ToolStripStatusLabel
 $statusLabel.Text = "State: Not Started"
 $statusBar.Items.Add($statusLabel) | out-null
 $progressBar = new-object Frm.ToolStripProgressBar
 $statusBar.Items.Add($progressBar) | out-null
 
 $tbPanel = new-object Frm.TableLayoutPanel
 $tbPanel.SuspendLayout()
 $tbPanel.Anchor = [Frm.AnchorStyles]([Frm.AnchorStyles]::Left -bor  [Frm.AnchorStyles]::Right -bor  [Frm.AnchorStyles]::Top -bor  [Frm.AnchorStyles]::Bottom )
 
 $tbPanel.ColumnCount = 2
 
 
 $tbPanel.ColumnStyles.Add((new-object Frm.ColumnStyle ([Frm.SizeType]::Percent, 50.0))) | out-null
 $tbPanel.ColumnStyles.Add((new-object Frm.ColumnStyle ([Frm.SizeType]::Percent, 50.0))) | out-null
 $tbPanel.RowCount = 2
 $tbPanel.RowStyles.Add((new-object Frm.RowStyle  ([Frm.SizeType]::Percent, 5))) | out-null
 $tbPanel.RowStyles.Add((new-object Frm.RowStyle  ([Frm.SizeType]::Percent, 95)))| out-null
 $tbPanel.Top = 170
 $tbPanel.Height=300
 $tbPanel.Width=$form.Width - 15
  
 $tbPanel.Controls.Add($lblDataReady,0,0)
 $tbPanel.Controls.Add($lblStateChanged,1,0)
 $tbPanel.Controls.Add($txtDataReady,0,1)
 $tbPanel.Controls.Add($txtStateChanged,1,1) 
 $form.Controls.Add($btnRun)
 $form.Controls.Add($btnCancel)
 $form.Controls.Add($btnView)
 $form.Controls.Add($lblStart)
 $form.Controls.Add($txtStart)
 $form.Controls.Add($lblEnd)
 $form.Controls.Add($txtEnd)
 $form.Controls.Add($lblSleep)
 $form.Controls.Add($txtSleep)

 $form.Controls.Add($tbPanel)
 $form.Controls.Add($statusBar)
 $form.Controls.Add($txtEnter)
 
 $tbPanel.ResumeLayout($false)
 $tbPanel.PerformLayout()
 $btnRun.Add_Click($btnRunClick)
 $btnCancel.Add_Click($btnCancelClick)
 $btnView.Add_Click($btnViewClick)
 
 $form.ShowDialog()| out-null
