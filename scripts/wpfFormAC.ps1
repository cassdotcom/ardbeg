#region HEADER
###########################################################
# .FILE		: wpfFormAC.ps1
# .AUTHOR  	: A.Cassidy
# .DATE    	: 2015-08-06
# .EDIT    	: 
# .FILE_ID	: 
# .COMMENT 	: Responsive GUI, requires WPFRunspace
# .INPUT	: None
# .OUTPUT	: None
#			  	
#           
# .VERSION : 1.0
###########################################################
###########################################################
# .CHANGELOG
# 2015-08-06 -- 1.0 -- Initial Release
#
#
###########################################################
# .INSTRUCTIONS FOR USE
# Run as scriptfile wpfFormAC.ps1
#
#
###########################################################
# .CONTENTS
# 
#
#
###########################################################
#endregion HEADER





#==========================================================
#region CONSTANTS
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Add accelerators for wpf (if you don't wish to use fully qualified paths).
# To prevent name conflicts you can use the -Prefix switch that will add 'Wpf.' prefix to accelerator.
add-WpfAccelerators 

$XAML_FILE = "C:\Users\ac00418\Documents\ardbeg\forms\wpfFormAC.xaml"
$NETWORK_NUMBERS = "C:\Users\ac00418\Documents\ardbeg\data\NETWORKS_NUMBERS.txt"
$CENSUS_LUA = "C:\Users\ac00418\Documents\ardbeg\data\CENSUS_LUA.txt"

$BUTTON_EXIT_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptBtnExit.ps1"

$BUTTON_1_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptBtnSide1.ps1"
$BUTTON_2_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptBtnSide2.ps1"
$BUTTON_3_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptBtnSide3.ps1"
$BUTTON_4_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptBtnSide4.ps1"

$btnSide3Done_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnSide3Data.ps1"

$btnSide1Click_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnSide1Click.ps1"
$btnSide2Click_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnSide2Click.ps1"
$btnSide3Click_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnSide3Click.ps1"

$BUTTON_SEARCH_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptBtnSearch.ps1"
$BUTTON_CANCEL_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\scriptbtnCancel.ps1"

$btnTBSearchClick_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnTBSearchClick.ps1"
$btnTBSearchData_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnTBSearchData.ps1"
$btnSearchDone_FILE = "C:\Users\ac00418\Documents\ardbeg\scripts\btnTBSearchDone.ps1"
#..........................................................
#endregion CONSTANTS
#==========================================================


#==========================================================
#region XAML
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$xaml = [io.file]::ReadAllText($XAML_FILE)
#..........................................................
#endregion XAML
#==========================================================




#==========================================================
#region BUTTON_FUNCTIONS
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
[scriptblock]$scriptBtnSide1 = Get-Command $BUTTON_1_FILE | select -ExpandProperty ScriptBlock
[scriptblock]$scriptBtnSide2 = Get-Command $BUTTON_2_FILE | select -ExpandProperty ScriptBlock
[scriptblock]$scriptBtnSide3 = Get-Command $BUTTON_3_FILE | select -ExpandProperty ScriptBlock

[scriptblock]$btnTBSearchClick = Get-Command $BUTTON_SEARCH_FILE | select -ExpandProperty ScriptBlock

# CLOSE FORM
[scriptblock]$scriptBtnExit = Get-Command $BUTTON_EXIT_FILE | select -ExpandProperty ScriptBlock
#..........................................................
#endregion BUTTON_FUNCTIONS
#==========================================================





#==========================================================
#region PIPELINE_DATA
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$dataReadySide1 = {
    # Get last item added to ready queue
    $lastItem = $Script:drWorker.GetReadyData()
    $script:count++ #This variable is for the progress bar
    if ($lastItem -ne $null -and $Script:drWorker.Errors.Count-eq 0)
    {
	    #$tbInput.Text += "`n$($lastItem)"
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')`t$($lastItem.Values)")
    }
    #$progressBar.Value = $Script:count/($script:end-$script:start + 1) * 100 # Update progress
    #$btnSide1.IsEnabled = $true

}

$dataReadySide2 = {
    # Get last item added to ready queue
    $lastItem = $Script:drWorker.GetReadyData()
    $script:count++ #This variable is for the progress bar
    if ($lastItem -ne $null -and $Script:drWorker.Errors.Count-eq 0)
    {
	    #$tbInput.Text += "`n$($lastItem)"
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')`t$($lastItem.Values)")
    }
    #$progressBar.Value = $Script:count/($script:end-$script:start + 1) * 100 # Update progress
}

$dataReadySide3 = {
    # Get last item added to ready queue
    $lastItem = $Script:drWorker.GetReadyData()
    $script:count++ #This variable is for the progress bar
    if ($lastItem -ne $null -and $Script:drWorker.Errors.Count-eq 0) {
	    $parish = $lastItem.Parish
        $rtbResults.AppendText("$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Data for postcode $($lastItem.PostCode)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') OA:`t$($lastItem.OA)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') COUNCIL:`t$($lastItem.Council)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') LOCALITY:`t$($lastItem.Locality)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') WARD:`t$($lastItem.Ward)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Parish:  `t$($lastItem.Parish)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') IntermediateZone:`t$($lastItem.Intermediate)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Parliament:`t$($lastItem.ScoParm)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') ParlRegion:`t$($lastItem.ScoParmReg)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Parl (UK):`t$($lastItem.UKParm)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Settlement:`t$($lastItem.Settlement)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') UrbanRural:`t$($lastItem.UrbanRural)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Easting:`t$($lastItem.Easting)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Northing:`t$($lastItem.Northing)")
        $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd_HH:mm:ss') Hectarage:`t$($lastItem.Hectarage)")
        $rtbResults.AppendText("`n`t----------------------------------------")
        $rtbResults.AppendText("`n")
        $rtbResults.ScrollToEnd()    }
    #$progressBar.Value = $Script:count/($script:end-$script:start + 1) * 100 # Update progress
}

$dataReadyTBSearch = (Get-Command $btnTBSearchData_FILE | select -ExpandProperty Scriptblock)
#..........................................................
#endregion PIPELINE_DATA
#==========================================================





#==========================================================
#region SCRIPT_CALL_FINISHED
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$btnSearchDone = (Get-Command $btnSearchDone_FILE | select -ExpandProperty ScriptBlock )

$stateChangedSide2 = {  
  
   #$rtbResults.AppendText("`nState: $($Script:drWorker.StateInfo.State)")
   # Completed,Stopped and Failed have higher enum value than stopping
   # When pipeline stops it will either be Stopped,Failed or Completed
   # In this example it does not matter which of the three state changes have
   # occurred as we simply output the results acheived to that point.
   # In other cases you may need to add your own clean-up code for the different states.
   if ($Script:drWorker.StateInfo.State -gt [PipelineState]::Stopping) {
        if ($Script:drWorker.Results.Count -gt 0) {
            # enable the button
	        $btnSide2.IsEnabled = $true
        }
        
        $tbInput.Text = "`n$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')`tErrors: $($Script:drWorker.Errors.Count)"
        if ($Script:drWorker.Errors.Count -gt 0) {
            foreach ($err in $Script:drWorker.Errors) {
                $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')`t$($err.Exception.Message)")
            }
        }

	} 
}


$stateChangedSide3 = (Get-Command $btnSide3Done_FILE| select -ExpandProperty ScriptBlock )

$stateChangedSide4 = {  
  
   if ($Script:drWorker.StateInfo.State -gt [PipelineState]::Stopping) {
        if ($Script:drWorker.Results.Count -gt 0) { $btnSide4.IsEnabled = $true}        
        $tbInput.Text = "`n$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')`tErrors: $($Script:drWorker.Errors.Count)"
        if ($Script:drWorker.Errors.Count -gt 0) {
            foreach ($err in $Script:drWorker.Errors) {
                $rtbResults.AppendText("`n$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')`t$($err.Exception.Message)")
            }
        }
	} 
}
#..........................................................
#endregion SCRIPT_CALL_FINISHED
#==========================================================





#==========================================================
#region CANCEL_SCRIPTBLOCK
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
[scriptblock]$btnCancelClick = Get-Command $BUTTON_CANCEL_FILE | select -ExpandProperty ScriptBlock
#..........................................................
#endregion CANCEL_SCRIPTBLOCK
#==========================================================





#==========================================================
#region BUTTON_CLICKS
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
[scriptblock]$btnTBSearchClick = Get-Command $btnTBSearchClick_FILE | select -ExpandProperty ScriptBlock

[scriptblock]$btnSide1Click = Get-Command $btnSide1Click_FILE | select -ExpandProperty ScriptBlock

[scriptblock]$btnSide2Click = Get-Command $btnSide2Click_FILE | select -ExpandProperty ScriptBlock

[Scriptblock]$btnSide3Click = Get-Command $btnSide3Click_FILE | select -ExpandProperty ScriptBlock

[Scriptblock]$btnSide4Click = {

    # Disable button
    $btnSide4.IsEnabled = $false
    $Script:count = 0

    # Get user input
    $Script:userValue = [string]($tbName.Text.ToString())
	$parameters4 = ([PSHelper]::NewPSParameter("PostCode",$Script:userValue),[PSHelper]::NewPSParameter("thisFunc",'DB'),[PSHelper]::NewPSParameter("doThis",$dd))

    # Now create backgroundworker 
	$Script:drWorker = New-WPFBackgroundWorker -ScriptBlock $scriptBtnSide4 -FrameworkElement $window -DataReadyAction $dataReadySide4 -StateChangedAction $stateChangedSide4 -Parameters $parameters4
	$progressBar.Visibility="Visible"
	$progressBar.Value=0
	
	#Start the backgroundworker
	$Script:drWorker | Invoke-WPFBackgroundWorker 
}
#..........................................................
#endregion BUTTON_CLICKS
#==========================================================




#==========================================================
#region WINDOW_CREATION
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
$window = [System.Windows.Window][System.Windows.Markup.XamlReader]::Parse($xaml)

# HEADER
# ------
[Label]$labelTitle = $window.FindName("labelTitle")
[Label]$labelFurther = $window.FindName("labelFurther")
[Button]$btnExit = $window.FindName("btnExit")
$labelFurther.Content = "READY"
$btnExit.Add_Click($scriptBtnExit)



# SIDEBAR
# -------
[TextBox]$tbName = $window.FindName("tbName")
[ComboBox]$cbCombo = $window.FindName("cbName")
[Button]$btnTBSearch = $window.FindName("btnTBSearch")
[Button]$btnCancel = $window.FindName("btnCancel")
[Button]$btnSide1 = $window.FindName("btSide1")
[Button]$btnSide2 = $window.FindName("btSide2")
[Button]$btnSide3 = $window.FindName("btSide3")
[Button]$btnSide4 = $window.FindName("btSide4")
[Button]$btnCancel = $window.FindName("btnCancel")
# Populate combobox
$list = Get-Content $CENSUS_LUA
foreach ( $n in $list ) { $cbCombo.Items.Add($n) | Out-Null }
# Button events
$btnTBSearch.Add_Click($btnTBSearchClick)
$btnCancel.Add_Click($btnCancelClick)
$btnSide1.Add_Click($btnSide1Click)
$btnSide2.Add_Click($btnSide2Click)
$btnSide3.Add_Click($btnSide3Click)
$btnSide4.Add_Click($btnSide4Click)

# MAIN BOX
# --------
[RichTextBox]$rtbResults = $window.FindName("rtbResults")
[TextBox]$tbInput = $window.FindName("tbInput")

# FOOTER
# ------
[ProgressBar]$progressBar = $window.FindName("pbProgress")

# STATUS BAR
# ----------
[StatusBar]$statusBar = $window.FindName("sbStatus")

# Show window
$window.ShowDialog() | out-null
#..........................................................
#endregion WINDOW_CREATION
#==========================================================
