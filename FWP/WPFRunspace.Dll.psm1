# ************************************************************************

#

# Script Name: .\WPFRunspace.Dll.ps1

# Version: 1.0.0.0

# Author: Pianoboy

# Date: 8/12/2014
#

#************************************************************************

 $path = "$PSScriptRoot\BackgroundWorker.cs"

 $source = [System.IO.File]::ReadAllText((Resolve-Path $path))

  
 $refs = (
             "System.Management.Automation",
            "System.Xml.Linq",
            "System.Windows.Forms","PresentationCore",
             "System.Configuration",
             "PresentationFramework",
             "WindowsBase")


$cSharp = "CSharp"

# Allow for version differences
 if ($PSVersionTable.PSVersion.Major -lt 4)
 {
    $cSharp = "CSharpVersion3"
    
 }
 else
 {
    $refs +="System.Xaml"
    
 }


if (!(Test-Path  "$PSScriptRoot\WPFRunspace.dll"))
{
    Add-Type  -TypeDefinition $source -ReferencedAssemblies $refs -Language $cSharp -IgnoreWarnings -OutputAssembly "$PSScriptRoot\WPFRunspace.dll" -OutputType Library -PassThru | out-null
}
else
{
     Add-Type  -Path "$PSScriptRoot\WPFRunspace.dll"
}

Add-Type  -AssemblyName System.Windows.Forms
Add-Type  -AssemblyName PresentationFramework

$xlr=[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators') 
$xlr::Add( "PipelineState", "System.Management.Automation.Runspaces.PipelineState" )
$xlr::Add( "BackgroundWorker", "WPFRunspace.BackgroundWorker" )
$xlr::Add( "PSParameter", "WPFRunspace.PSParameter" )
$xlr::Add( "PSHelper", "WPFRunspace.PSHelper" )
$xlr::Add('accelerators',$xlr)


<#
.SUMMARY
Add WPF Accelerators
.DESCRIPTION
This will add WPF types without the requirement to use a fully qualified namespace.
e.g. [Window] insead of [System.Windows.Window]
.PARAMETER Prefix
If using both Win Forms and WPF types within a script there will be name conflicts.
If the Prefix switch is used all WPF type names will be prefixed with 'Wpf.".
e.g For a [window] acceleratopr use [Wpf.Window] instead.
#>

Function Add-WpfAccelerators
{
    [CmdletBinding()]
        param([Parameter(Position=0)][switch]$Prefix)

    $_prefix = ""
    if ($Prefix)
    {
        $_prefix = "Wpf."
    }
    $xlr=[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $wpf = [system.reflection.assembly]::LoadWithPartialName("PresentationFramework")
    $wpf.GetTypes() | where {$_.IsPublic -and 
        $_.BaseType -ne [System.Object] -and $_.BaseType -ne [System.Attribute]} |
         foreach {
            $xlr::Add( "$_prefix$($_.Name)", $_.FullName )}
    $xlr::Add('accelerators',$xlr)
    
}

<#
.SUMMARY
Add Win Forms Accelerators
.DESCRIPTION
This will add Win Forms types without the requirement to use a fully qualified namespace.
e.g. [Form] insead of [System.Windows.Forms.Form]
.PARAMETER Prefix
If using both Win Forms and WPF types within a script there will be name conflicts.
If the Prefix switch is used all Win Form type names will be prefixed with 'Frm.".
e.g For a [Form] acceleratopr use [Frm.Window] instead.
#>

Function Add-WinFormsAccelerators
{
    [CmdletBinding()]
        param([Parameter(Position=0)][switch]$Prefix)

    $_prefix = ""
    if ($Prefix)
    {
        $_prefix = "Frm."
    }

    $xlr=[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    $wpf = [system.reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
    $wpf.GetTypes() | where {$_.IsPublic -and 
        $_.BaseType -ne [System.Object] -and $_.BaseType -ne [System.Attribute]} |
         foreach {
             $xlr::Add( "$_prefix$($_.Name)", $_.FullName )}
    $xlr::Add('accelerators',$xlr)
 
}




<#
.SYNOPSIS
Creates a WPFBackgroundWorker that may be used to execute long running scripts
in a thread separate to the WPF Gui thread. 
.DESCRIPTION

.PARAMETER FrameworkElement
To access WPF elements on the main Gui thread requires accessing the dispatch thread.
The dispatcher is present on any WPF element that derives from the FrameworkElement.
As such the WPFBackgroundWorker must be provided with either the Window object or
a Control object that will be moified on completion by the DataReadyAction or StateChangedAction.
.PARAMETER ScriptBlock
The scriptblock to run in a separate powershell runspace.
.PARAMETER Parameters
Any parmaters to be input into the scriptblock must be an array of PSParameter objects.
A PSParameter object is simply a Name/Value pair.
The WPFRunspace.PSHelper class provides a static method to create a PSParameter.
    [PSHelper]::NewPSparameter("[The parameter name]",[The parameter value])
.PARAMETER DataReadyAction
The runspace can return pipeline data as it becomes ready. You can provide a scriptblock that is run
whenever data becomes available. The data may be accessed via the Results property of the WPFBackgroundWorker.
The "Results" property returned is cumulative. 
.PARAMETER StateChangedAction
If  data is only required to be updated once everything is complete then provide a scriptblock for this parameter.
The states that may be captured are Not Started, Running, Completed or failed.
In your script you can capture the state using the StateInfo.State property. 
.OUTPUTS
Outputs a new WPFRunspace.BackgroundWorker object.
#>
function New-WPFBackgroundWorker
{
    [CmdletBinding(DefaultParameterSetName="WPF")]
    param([Parameter(Mandatory=$false,Position=0,ParameterSetName="WPF")][System.Windows.FrameworkElement]$FrameworkElement,
        [Parameter(Mandatory=$false,Position=1,ParameterSetName="Forms")][System.Windows.Forms.Control]$Control,
        [Parameter(Mandatory=$true,Position=2)][ScriptBlock]$ScriptBlock,
        [Parameter(Position=3)][PSParameter[]]$Parameters,
        [Parameter(Position=4)][ScriptBlock]$DataReadyAction,
        [Parameter(Position=5)][ScriptBlock]$StateChangedAction
        )

    [BackgroundWorker]$bgWorker = $null
    if ($PSBoundParameters.ContainsKey("FrameworkElement"))
    {
        $bgWorker = [PSHelper]::CreateBGWorker($FrameworkElement)
    }
    elseif ($PSBoundParameters.ContainsKey("Control"))
    {
        $bgWorker = [PSHelper]::CreateBGWorker($Control)
    }
    else
    {
        $bgWorker = [PSHelper]::CreateBGWorker()
    }
    $bgWorker.ScriptBlock = $ScriptBlock
    if ($PSBoundParameters.ContainsKey("Parameters"))
    {
       $bgWorker.Parameters = $Parameters
    }
    if ($PSBoundParameters.ContainsKey("DataReadyAction"))
    {
       $bgWorker.DataReadyAction = $DataReadyAction
    }
    if ($PSBoundParameters.ContainsKey("StateChangedAction"))
    {
       $bgWorker.StateChangedAction = $StateChangedAction
    }
    
    $bgWorker

}

<#
.SYNOPSIS
A convenience function to enable the pipelining of WPFBackgroundWorker invocation.
.DESCRIPTION
A convenience function to enable invoking several WPFBackgroundWorkers via the pipeline.
Note that you can invoke a WPFBackgroundWorker simply by using the overloaded Invoke() method as below:-
$bgWorker.Invoke(). Run Show-WPFRunspaceHelp for more information

Invocation will create a new runspace to execute a scriptblock.

.PARAMETER Workers
An array of [WPFRunspace.BackgroundWorker] objects.
.PARAMETER ScriptBlock
A scriptblock to be executed in a new runspace pipeline.
This parameter may be used run a different script to the ScriptBlock Property previously set
by the New-WPFBackgroundWorker cmdlet. Generally you do not need to use this.
.PARAMETER Parameters
An array of PSParameter objects to provide parameters required by the executing scriptblock.
Only use this if you need to as a result of providing a ScriptBlock parameter.
Generally this should not be required if parameters have been already provided to the 
New-WPFBackgroundWorker cmdlet.
#>
function Invoke-WPFBackgroundWorker
{
        [CmdletBinding()]
    param([Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][BackgroundWorker[]]$Workers,
        [Parameter(Position=1,ValueFromPipeline=$false)][ScriptBlock]$ScriptBlock,
        [Parameter(Position=2,ValueFromPipeline=$false)][PSParameter[]]$Parameters
    )
    BEGIN
    {
        $command = '$bgWorker.Invoke('
        if ($PSBoundParameters.ContainsKey("ScriptBlock"))
        {
            $command +='$ScriptBlock,'
        }
        else 
        {
            $command +='$bgWorker.ScriptBlock,'
        }

        if ($PSBoundParameters.ContainsKey("Parameters"))
        {
            $command +='$Parameters)'
        }
        else 
        {
            $command +='$bgWorker.Parameters)'
        }

         
    }


    PROCESS
    {
        foreach ($bgWorker in $Workers)
        {
            Invoke-Expression $command 
        }    
    }

}

<#
.SYNOPSIS
Convenience function to show a WPF example using WPFRunspace.BckgroundWorker
.DESCRIPTION
Convenience method to show a WPF example using WPFRunspace.BckgroundWorker.
The example includes a button to let you view the code in ISE.
#>
function Show-WPFExample
{
    start-process powershell -ArgumentList "-noexit", "-noprofile", "-command & $PSScriptRoot\Example\Invoke-WpfWorkerExample.ps1"
}


<#
.SYNOPSIS
Convenience function to show a Win Forms example using WPFRunspace.BckgroundWorker
.DESCRIPTION
Convenience method to show a WinForms example using WPFRunspace.BckgroundWorker.
The example includes a button to let you view the code in ISE.
#>
function Show-WinFormsExample
{
  start-process powershell -ArgumentList "-noexit", "-noprofile", "-command & $PSScriptRoot\Example\Invoke-FormWorkerExample.ps1"
}


<#
.SYNOPSIS
Convenience function to open the  WPFRunspaceHelp.chm file.
#>
function Get-WPFRunspaceHelp
{
    &"$PSScriptRoot\WPFRunspaceHelp.chm"
}

