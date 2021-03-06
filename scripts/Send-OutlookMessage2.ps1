#region Import Assemblies
[void][Reflection.Assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
[void][Reflection.Assembly]::Load("mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
[void][Reflection.Assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
#endregion Import Assemblies

function Main {
    Param ([String]$Commandline)
    if((Call-Send-OutlookMessageForm_pff) -eq "OK")
    {}
    $global:ExitCode = 0
}

#region Globals
    function Send-OutlookMessage
{

    Param(
        [System.String]
        $emailTo,
        [System.String]
        $emailSubject,
        [System.String]
        $emailBody,
		[Switch]
		$pthru
    )
	
	
	$ol = New-Object -ComObject outlook.application
    $mail = $ol.CreateItem(0)

    $mail.Recipients.Add($emailTo)
    $mail.Subject = $emailSubject
    $mail.Body = $emailBody

    $mail.Send()
	

}


    
    # Global Variables
    $OutputToGrid = $false
	$LaunchAsSeperateProcess = $false
    $FunctionName = 'Send-OutlookMessage'
    $FunctionPath = 'C:\repo\ardbeg\Send-OutlookMessage.ps1'
    $FunctionIsExternal = $false
    
    $FunctionParamTypes = @{}
        $FunctionParamTypes.Add("checkbox_pthru","checkbox")

    
    $MandatoryParams = @{}
    $MandatoryParams.Add("emailTo",$False)
$MandatoryParams.Add("emailSubject",$False)
$MandatoryParams.Add("emailBody",$False)
$MandatoryParams.Add("pthru",$False)

    
    # Global functions
    function Out-GridViewForm 
    {
        <#
        .SYNOPSIS
            Create a generic datagrid view of data.
        .DESCRIPTION
            Create a generic datagrid view of data. An option to export to CSV is available as well.
            This is a cheap and dirty replacement for out-gridview.
        .PARAMETER ScriptOutput
            The results of script data you want to display in the grid.
        .EXAMPLE
            Get-Process | 
                Sort-Object CPU -Descending | 
                Select-Object Name,CPU -First 10 | 
                Out-GridViewForm
    
            Description
            -----------
            Get the top 10 CPU utilizing processes and displays them in a gridview.
        .NOTES
            Author: Zachary Loeber
            Requires: Powershell 2.0
    
            Version History
            1.0 - 01/30/2014
                - Initial release
        .LINK
            http://www.the-little-things.net/
        .LINK
            http://nl.linkedin.com/in/zloeber
        #>
        [CmdletBinding()]
        param
        (
            [Parameter(HelpMessage="Array of object results from powershell command or function.",
                       ValueFromPipeline=$true,
                       Position=0)]
            [ValidateNotNullOrEmpty()]
            $ScriptResults
        )
        BEGIN
        {
            $AllScriptResults = @()
        }
        PROCESS
        {
            $AllScriptResults += $ScriptResults
        }
        END
        {
            function Call-DatagridOutputForm_pff
            {
                #region Import the Assemblies
                [void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
                [void][reflection.assembly]::Load("mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][reflection.assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
                [void][reflection.assembly]::Load("System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][reflection.assembly]::Load("System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
                #endregion Import Assemblies
    
                #region Generated Form Objects
                [System.Windows.Forms.Application]::EnableVisualStyles()
                $formScriptResults = New-Object 'System.Windows.Forms.Form'
                $buttonExportToCSV = New-Object 'System.Windows.Forms.Button'
                $datagridviewResults = New-Object 'System.Windows.Forms.DataGridView'
                $buttonExit = New-Object 'System.Windows.Forms.Button'
                $savefiledialog1 = New-Object 'System.Windows.Forms.SaveFileDialog'
                $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
                #endregion Generated Form Objects
    
                # User Generated Script
                function OnApplicationLoad {
                    return $true
                }
                
                function OnApplicationExit {
                    $script:ExitCode = 0
                }
                
                #region Control Helper Functions
                function Load-DataGridView
                {
                    <#
                    .SYNOPSIS
                        This functions helps you load items into a DataGridView.
                
                    .DESCRIPTION
                        Use this function to dynamically load items into the DataGridView control.
                
                    .PARAMETER  DataGridView
                        The ComboBox control you want to add items to.
                
                    .PARAMETER  Item
                        The object or objects you wish to load into the ComboBox's items collection.
                    
                    .PARAMETER  DataMember
                        Sets the name of the list or table in the data source for which the DataGridView is displaying data.
                
                    #>
                    Param (
                        [ValidateNotNull()]
                        [Parameter(Mandatory=$true)]
                        [System.Windows.Forms.DataGridView]$DataGridView,
                        [ValidateNotNull()]
                        [Parameter(Mandatory=$true)]
                        $Item,
                        [Parameter(Mandatory=$false)]
                        [string]$DataMember
                    )
                    $DataGridView.SuspendLayout()
                    $DataGridView.DataMember = $DataMember
                    
                    if ($Item -is [System.ComponentModel.IListSource]`
                    -or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView] )
                    {
                        $DataGridView.DataSource = $Item
                    }
                    else
                    {
                        $array = New-Object System.Collections.ArrayList
                        
                        if ($Item -is [System.Collections.IList])
                        {
                            $array.AddRange($Item)
                        }
                        else
                        {    
                            $array.Add($Item)    
                        }
                        $DataGridView.DataSource = $array
                    }
                    
                    $DataGridView.ResumeLayout()
                }
                
                function ConvertTo-DataTable
                {
                    <#
                        .SYNOPSIS
                            Converts objects into a DataTable.
                    
                        .DESCRIPTION
                            Converts objects into a DataTable, which are used for DataBinding.
                    
                        .PARAMETER  InputObject
                            The input to convert into a DataTable.
                    
                        .PARAMETER  Table
                            The DataTable you wish to load the input into.
                    
                        .PARAMETER RetainColumns
                            This switch tells the function to keep the DataTable's existing columns.
                        
                        .PARAMETER FilterWMIProperties
                            This switch removes WMI properties that start with an underline.
                    
                        .EXAMPLE
                            $DataTable = ConvertTo-DataTable -InputObject (Get-Process)
                    #>
                    [OutputType([System.Data.DataTable])]
                    param(
                    [ValidateNotNull()]
                    $InputObject, 
                    [ValidateNotNull()]
                    [System.Data.DataTable]$Table,
                    [switch]$RetainColumns,
                    [switch]$FilterWMIProperties)
                    
                    if($Table -eq $null)
                    {
                        $Table = New-Object System.Data.DataTable
                    }
                
                    if($InputObject-is [System.Data.DataTable])
                    {
                        $Table = $InputObject
                    }
                    else
                    {
                        if(-not $RetainColumns -or $Table.Columns.Count -eq 0)
                        {
                            #Clear out the Table Contents
                            $Table.Clear()
                
                            if($InputObject -eq $null){ return } #Empty Data
                            
                            $object = $null
                            #find the first non null value
                            foreach($item in $InputObject)
                            {
                                if($item -ne $null)
                                {
                                    $object = $item
                                    break    
                                }
                            }
                
                            if($object -eq $null) { return } #All null then empty
                            
                            #Get all the properties in order to create the columns
                            foreach ($prop in $object.PSObject.Get_Properties())
                            {
                                if(-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__'))#filter out WMI properties
                                {
                                    #Get the type from the Definition string
                                    $type = $null
                                    
                                    if($prop.Value -ne $null)
                                    {
                                        try{ $type = $prop.Value.GetType() } catch {}
                                    }
                
                                    if($type -ne $null) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
                                    {
                                          [void]$table.Columns.Add($prop.Name, $type) 
                                    }
                                    else #Type info not found
                                    { 
                                        [void]$table.Columns.Add($prop.Name)     
                                    }
                                }
                            }
                            
                            if($object -is [System.Data.DataRow])
                            {
                                foreach($item in $InputObject)
                                {    
                                    $Table.Rows.Add($item)
                                }
                                return  @(,$Table)
                            }
                        }
                        else
                        {
                            $Table.Rows.Clear()    
                        }
                        
                        foreach($item in $InputObject)
                        {        
                            $row = $table.NewRow()
                            
                            if($item)
                            {
                                foreach ($prop in $item.PSObject.Get_Properties())
                                {
                                    if($table.Columns.Contains($prop.Name))
                                    {
                                        $row.Item($prop.Name) = $prop.Value
                                    }
                                }
                            }
                            [void]$table.Rows.Add($row)
                        }
                    }
                
                    return @(,$Table)    
                }
                #endregion
                
                $FormEvent_Load={
                    if ($ScriptResults)
                    {
                        Load-DataGridView -DataGridView $datagridviewResults -Item (ConvertTo-DataTable $AllScriptResults)
                    }
                }
                
                $buttonExit_Click={
                    $formScriptResults.Close()
                }
    
                $datagridviewResults_ColumnHeaderMouseClick=[System.Windows.Forms.DataGridViewCellMouseEventHandler]{
                #Event Argument: $_ = [System.Windows.Forms.DataGridViewCellMouseEventArgs]
                    if($datagridviewResults.DataSource -is [System.Data.DataTable])
                    {
                        $column = $datagridviewResults.Columns[$_.ColumnIndex]
                        $direction = [System.ComponentModel.ListSortDirection]::Ascending
                        
                        if($column.HeaderCell.SortGlyphDirection -eq 'Descending')
                        {
                            $direction = [System.ComponentModel.ListSortDirection]::Descending
                        }
                
                        $datagridviewResults.Sort($datagridviewResults.Columns[$_.ColumnIndex], $direction)
                    }
                }
                
                $buttonExportToCSV_Click={
                    if($savefiledialog1.ShowDialog() -eq 'OK')
                    {
                        try
                        {
                            $filename = $savefiledialog1.FileName
                            $datagridviewResults.Rows |
                                select -expand DataBoundItem |
                                    export-csv $filename -NoTypeInformation
                            #[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                            [void][System.Windows.Forms.MessageBox]::Show("Data exported successfully!","Success!")
                        }
                        catch
                        {
                            #[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                            [void][System.Windows.Forms.MessageBox]::Show("Error exporting data.","Error!")
                        }
                    }
                }    # --End User Generated Script--
    
                #region Generated Events
                $Form_StateCorrection_Load=
                {
                    #Correct the initial state of the form to prevent the .Net maximized form issue
                    $formScriptResults.WindowState = $InitialFormWindowState
                }
                
                $Form_Cleanup_FormClosed=
                {
                    #Remove all event handlers from the controls
                    try
                    {
                        $buttonExportToCSV.remove_Click($buttonExportToCSV_Click)
                        $datagridviewResults.remove_ColumnHeaderMouseClick($datagridviewResults_ColumnHeaderMouseClick)
                        $buttonExit.remove_Click($buttonExit_Click)
                        $formScriptResults.remove_Load($FormEvent_Load)
                        $formScriptResults.remove_Load($Form_StateCorrection_Load)
                        $formScriptResults.remove_FormClosed($Form_Cleanup_FormClosed)
                    }
                    catch [Exception]
                    { }
                }
                #endregion Generated Events
    
                #region Generated Form Code
                $formScriptResults.Controls.Add($buttonExportToCSV)
                $formScriptResults.Controls.Add($datagridviewResults)
                $formScriptResults.Controls.Add($buttonExit)
                $formScriptResults.ClientSize = '584, 374'
                $formScriptResults.Name = "formScriptResults"
                $formScriptResults.StartPosition = 'CenterScreen'
                $formScriptResults.Text = "Script Results"
                $formScriptResults.add_Load($FormEvent_Load)
    
                # buttonExportToCSV
                $buttonExportToCSV.Anchor = 'Bottom, Left'
                $buttonExportToCSV.Location = '12, 338'
                $buttonExportToCSV.Name = "buttonExportToCSV"
                $buttonExportToCSV.Size = '104, 23'
                $buttonExportToCSV.TabIndex = 3
                $buttonExportToCSV.Text = "Export To CSV"
                $buttonExportToCSV.UseVisualStyleBackColor = $True
                $buttonExportToCSV.add_Click($buttonExportToCSV_Click)
    
                # datagridviewResults
                $datagridviewResults.AllowUserToAddRows = $False
                $datagridviewResults.AllowUserToDeleteRows = $False
                $datagridviewResults.Anchor = 'Top, Bottom, Left, Right'
                $datagridviewResults.Location = '12, 12'
                $datagridviewResults.Name = "datagridviewResults"
                $datagridviewResults.ReadOnly = $True
                $datagridviewResults.Size = '560, 321'
                $datagridviewResults.TabIndex = 2
                $datagridviewResults.add_ColumnHeaderMouseClick($datagridviewResults_ColumnHeaderMouseClick)
    
                # buttonExit
                $buttonExit.Anchor = 'Bottom, Right'
                $buttonExit.Location = '497, 339'
                $buttonExit.Name = "buttonExit"
                $buttonExit.Size = '75, 23'
                $buttonExit.TabIndex = 1
                $buttonExit.Text = "E&xit"
                $buttonExit.UseVisualStyleBackColor = $True
                $buttonExit.add_Click($buttonExit_Click)
    
                # savefiledialog1
                $savefiledialog1.DefaultExt = "csv"
                $savefiledialog1.Filter = "Comma Separated Value (.csv)|*.csv|All Files|*.*"
                #endregion Generated Form Code
    
                #Save the initial state of the form
                $InitialFormWindowState = $formScriptResults.WindowState
                #Init the OnLoad event to correct the initial state of the form
                $formScriptResults.add_Load($Form_StateCorrection_Load)
                #Clean up the control events
                $formScriptResults.add_FormClosed($Form_Cleanup_FormClosed)
                #Show the Form
                return $formScriptResults.ShowDialog()
            }
            Call-DatagridOutputForm_pff | Out-Null
        }
    }

	Function Convert-SplatToString ($Splat)
	{
		BEGIN
		{
			Function Escape-PowershellString ([string]$InputString)
			{
				$replacements = @{
					'!' = '`!' 
					'"' = '`"'
					'$' = '`$'
					'%' = '`%'
					'*' = '`*'
					"'" = "`'"
					' ' = '` '
					'#' = '`#'
					'@' = '`@'
					'.' = '`.'
					'=' = '`='
					',' = '`,'
				}

				# Join all (escaped) keys from the hashtable into one regular expression.
				[regex]$r = @($replacements.Keys | foreach { [regex]::Escape( $_ ) }) -join '|'

				$matchEval = { param( [Text.RegularExpressions.Match]$matchInfo )
				  # Return replacement value for each matched value.
				  $matchedValue = $matchInfo.Groups[0].Value
				  $replacements[$matchedValue]
				}

				$InputString | Foreach { $r.Replace( $_, $matchEval ) }
			}
		}
		PROCESS
		{
		}
		END
		{
			$ResultSplat = ''
			Foreach ($SplatName in $Splat.Keys)
			{
				switch ((($Splat[$SplatName]).GetType()).Name) {
					'Boolean' {
						if ($Splat[$SplatName] -eq $true)
						{
							$SplatVal = '$true'
						}
						else
						{
							$SplatVal = '$false'
						}
						break
					}
					'String' {
						$SplatVal = '"' + $(Escape-PowershellString $Splat[$SplatName]) + '"'
						break
					}
					default {
						$SplatVal = $Splat[$SplatName]
						break
					}
				}
				$ResultSplat = $ResultSplat + '-' + $SplatName + ':' + $SplatVal + ' '
			}
			$ResultSplat
		}
	}


	#endregion Globals

#region Send-OutlookMessageForm.pff
function Call-Send-OutlookMessageForm_pff
{
    #----------------------------------------------
    #region Import the Assemblies
    #----------------------------------------------
    [void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    [void][reflection.assembly]::Load("mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    #endregion Import Assemblies

    #region Generated Form Objects
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $Send-OutlookMessage_Form = New-Object 'System.Windows.Forms.Form'
    $formpanel = New-Object 'System.Windows.Forms.Panel'
    $textbox_CommentBasedHelp = New-Object 'System.Windows.Forms.TextBox'
    $buttonExecute = New-Object 'System.Windows.Forms.Button'
    $tooltip = New-Object 'System.Windows.Forms.ToolTip'
    $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
        $checkbox_pthru = New-Object 'System.Windows.Forms.CheckBox'

    #endregion Generated Form Objects

    # User Generated Script
    $OnLoadFormEvent={}
    
    $buttonExecute_Click={
        # Create our function splat
        $ValidParamSplat = $true
        $FunctionCallSplat = @{}
        Foreach ($funcparam in $FunctionParamTypes.keys)
        {
            switch ($FunctionParamTypes[$funcparam]) {
                'switch' {
                    $ParamName = $funcparam -replace 'switch_',''
                    $ControlString = '$' + $funcparam
                    $ControlName = [Scriptblock]::Create($ControlString)
                    $FunctionCallSplat.[string]$ParamName = $(Invoke-Command $ControlName).Checked
                }
				'checkbox' {
                $ParamName = $funcparam -replace 'checkbox_',''
                $ControlString = '$' + $funcparam
                $ControlName = [Scriptblock]::Create($ControlString)
                $FunctionCallSplat.[string]$ParamName = $(Invoke-Command  $ControlName).Checked
				}
                'bool' {
                    $ParamName = $funcparam -replace 'bool_',''
                    $ControlString = '$' + $funcparam
                    $ControlName = [Scriptblock]::Create($ControlString)
                    $FunctionCallSplat.[string]$ParamName = $(Invoke-Command $ControlName).Checked
                }
                'string' {
                    $ParamName = $funcparam -replace 'textbox_',''
                    $ControlString = '$' + $funcparam
                    $ControlName = [Scriptblock]::Create($ControlString)
                    $FunctionCallSplat.[string]$ParamName = $(Invoke-Command $ControlName).Text
                }
                'int' {
                    $ParamName = $funcparam -replace 'dial_',''
                    $ControlString = '$' + $funcparam
                    $ControlName = [Scriptblock]::Create($ControlString)
                    $FunctionCallSplat.[string]$ParamName = $(Invoke-Command $ControlName).Value
                }
                'combobox' {
                    $ParamName = $funcparam -replace 'combobox_',''
                    $ControlString = '$' + $funcparam
                    $ControlName = [Scriptblock]::Create($ControlString)
                    $ComboValue = $(Invoke-Command  $ControlName).Text
                    if ($ComboValue -eq '')
                    {
                        $ValidParamSplat = $false
                        #[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                        [void][System.Windows.Forms.MessageBox]::Show("Missing Mandatory Parameter: $ParamName","Error!")
                    }
                    else
                    {
                        $FunctionCallSplat.[string]$ParamName = $ComboValue
                    }
                }
            }         
        }
    
        # Validate all mandatory parameters are present
        if ($ValidParamSplat)
        {
            foreach ($MParam in $MandatoryParams.keys)
            {
                if ($MandatoryParams[$MParam])
                {
                    If (! $FunctionCallSplat.ContainsKey($MParam))
                    {
                        $ValidParamSplat = $false
                        #[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                        [void][System.Windows.Forms.MessageBox]::Show("Missing Mandatory Parameter: $MParam","Error!")
                    }
                }
            }
        }
        
        if ($ValidParamSplat)
        {
            if ($FunctionIsExternal)
            {
                $FunctionCallSplatString = Convert-SplatToString $FunctionCallSplat
                #$FunctionCommand = $FunctionPath + " @FunctionCallSplat"
				$FunctionCommand = "Start-Process powershell.exe -ArgumentList '-NoExit -c " + $FunctionPath + " $FunctionCallSplatString" + "'"
            }
            else
            {
                $FunctionCommand = $FunctionName + " @FunctionCallSplat"
            }
            
            if ($OutputToGrid)
            {
                $FunctionCommand = $FunctionCommand + ' | Out-GridViewForm'
            }
    
            $FunctionToCall = [Scriptblock]::Create($FunctionCommand)
            Invoke-Command $FunctionToCall
        }
    }
    #region Control Helper Functions
    function Load-ComboBox 
    {
    <#
        .SYNOPSIS
            This functions helps you load items into a ComboBox.
    
        .DESCRIPTION
            Use this function to dynamically load items into the ComboBox control.
    
        .PARAMETER  ComboBox
            The ComboBox control you want to add items to.
    
        .PARAMETER  Items
            The object or objects you wish to load into the ComboBox's Items collection.
    
        .PARAMETER  DisplayMember
            Indicates the property to display for the items in this control.
        
        .PARAMETER  Append
            Adds the item(s) to the ComboBox without clearing the Items collection.
        
        .EXAMPLE
            Load-ComboBox $combobox1 "Red", "White", "Blue"
        
        .EXAMPLE
            Load-ComboBox $combobox1 "Red" -Append
            Load-ComboBox $combobox1 "White" -Append
            Load-ComboBox $combobox1 "Blue" -Append
        
        .EXAMPLE
            Load-ComboBox $combobox1 (Get-Process) "ProcessName"
    #>
        Param (
            [ValidateNotNull()]
            [Parameter(Mandatory=$true)]
            [System.Windows.Forms.ComboBox]$ComboBox,
            [ValidateNotNull()]
            [Parameter(Mandatory=$true)]
            $Items,
            [Parameter(Mandatory=$false)]
            [string]$DisplayMember,
            [switch]$Append
        )
        
        if(-not $Append)
        {
            $ComboBox.Items.Clear()    
        }
        
        if($Items -is [Object[]])
        {
            $ComboBox.Items.AddRange($Items)
        }
        elseif ($Items -is [Array])
        {
            $ComboBox.BeginUpdate()
            foreach($obj in $Items)
            {
                $ComboBox.Items.Add($obj)    
            }
            $ComboBox.EndUpdate()
        }
        else
        {
            $ComboBox.Items.Add($Items)    
        }
    
        $ComboBox.DisplayMember = $DisplayMember    
    }
    #endregion    # --End User Generated Script--

    #region Generated Events
    $Form_StateCorrection_Load=
    {
        #Correct the initial state of the form to prevent the .Net maximized form issue
        $Send-OutlookMessage_Form.WindowState = $InitialFormWindowState
    }
    
    $Form_StoreValues_Closing=
    {
        #Store the control values
#        $script:ExampleOutputForm_checkbox_<#ParamSwitch#> = $checkbox_<#ParamSwitch#>.Checked
#        $script:ExampleOutputForm_textbox_<#ParamString#> = $textbox_<#ParamString#>.Text
#        $script:ExampleOutputForm_combobox_<#ParamStringValidateSet#> = $combobox_<#ParamStringValidateSet#>.Text
#        $script:ExampleOutputForm_textbox_CommentBasedHelp = $textbox_CommentBasedHelp.Text
    }

    
    $Form_Cleanup_FormClosed=
    {
        #Remove all event handlers from the controls
        try
        {
            $buttonExecute.remove_Click($buttonExecute_Click)
            $Send-OutlookMessage_Form.remove_Load($OnLoadFormEvent)
            $Send-OutlookMessage_Form.remove_Load($Form_StateCorrection_Load)
            $Send-OutlookMessage_Form.remove_Closing($Form_StoreValues_Closing)
            $Send-OutlookMessage_Form.remove_FormClosed($Form_Cleanup_FormClosed)
        }
        catch [Exception]
        { }
    }
    #endregion Generated Events

    #region Generated Form Code

    # Send-OutlookMessage_Form
    $Send-OutlookMessage_Form.Controls.Add($formpanel)
    $Send-OutlookMessage_Form.Controls.Add($textbox_CommentBasedHelp)
    $Send-OutlookMessage_Form.Controls.Add($buttonExecute)
    $Send-OutlookMessage_Form.AcceptButton = $buttonExecute
    $Send-OutlookMessage_Form.AutoScroll = $True
    $Send-OutlookMessage_Form.AutoSizeMode = 'GrowAndShrink'
    $Send-OutlookMessage_Form.ClientSize = '756, 303'
    $Send-OutlookMessage_Form.FormBorderStyle = 'FixedDialog'
    $Send-OutlookMessage_Form.MaximizeBox = $False
    $Send-OutlookMessage_Form.MinimizeBox = $False
    $Send-OutlookMessage_Form.Name = "Send-OutlookMessage_Form"
    $Send-OutlookMessage_Form.StartPosition = 'CenterScreen'
    $Send-OutlookMessage_Form.Text = "Send-OutlookMessage GUI"
    $Send-OutlookMessage_Form.add_Load($OnLoadFormEvent)

    # formpanel
    $formpanel.Anchor = 'Top, Bottom, Left'
    $formpanel.AutoScroll = $True
    $formpanel.AutoSizeMode = 'GrowAndShrink'
    $formpanel.BorderStyle = 'Fixed3D'
    $formpanel.Location = '12, 12'
    $formpanel.Name = "formpanel"
    $formpanel.Size = '397, 260'
    $formpanel.TabIndex = 0
    
    # Custom form controls
    
    # checkbox_pthru
    $formpanel.Controls.Add($checkbox_pthru)      #Add control to panel
    $checkbox_pthru.Anchor = 'Top, Left, Right'
    $checkbox_pthru.Location = '3, 10'
    $checkbox_pthru.Name = "checkbox_pthru"
    $tooltip.SetToolTip($checkbox_pthru, "")
    $checkbox_pthru.Size = '385, 20'
    $checkbox_pthru.TabIndex = 0
    $checkbox_pthru.Text = "pthru"
    $checkbox_pthru.UseVisualStyleBackColor = $True


    # textbox_CommentBasedHelp
    $textbox_CommentBasedHelp.Anchor = 'Top, Bottom, Right'
    $textbox_CommentBasedHelp.Location = '415, 12'
    $textbox_CommentBasedHelp.Multiline = $True
    $textbox_CommentBasedHelp.Name = "textbox_CommentBasedHelp"
    $textbox_CommentBasedHelp.ScrollBars = 'Both'
    $textbox_CommentBasedHelp.Size = '329, 260'
    $textbox_CommentBasedHelp.TabIndex = 100
    $textbox_CommentBasedHelp.Text = ""

    # buttonExecute
    $buttonExecute.Anchor = 'Bottom, Right'
    $buttonExecute.Location = '669, 277'
    $buttonExecute.Name = "buttonExecute"
    $buttonExecute.Size = '75, 23'
    $buttonExecute.TabIndex = 1
    $buttonExecute.Text = "Execute"
    $buttonExecute.UseVisualStyleBackColor = $True
    $buttonExecute.add_Click($buttonExecute_Click)
    #endregion Generated Form Code

    #Save the initial state of the form
    $InitialFormWindowState = $Send-OutlookMessage_Form.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $Send-OutlookMessage_Form.add_Load($Form_StateCorrection_Load)
    #Clean up the control events
    $Send-OutlookMessage_Form.add_FormClosed($Form_Cleanup_FormClosed)
    #Store the control values when form is closing
    $Send-OutlookMessage_Form.add_Closing($Form_StoreValues_Closing)
    #Show the Form
    return $Send-OutlookMessage_Form.ShowDialog()

}
#endregion Send-OutlookMessageForm.pff

#Start the application
Main ($CommandLine)
