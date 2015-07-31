#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.26
# Created on:   12/07/2015 16:54
# Created by:   cass
# Organization: 
# Filename:     
#========================================================================


Param(
    [Parameter(Mandatory=$false)]
    [System.Management.Automation.ScriptBlock]
    $jobScript,
	[System.String]
	$jobDetails,
	[Switch]
	$jobCheck
)

if ( $jobCheck ) {
	
	Receive-Job -Name $jobDetails -Keep
	
} else {
	
	$thisJob = Start-Job -Name $jobDetails -ScriptBlock $jobScript
	
}

