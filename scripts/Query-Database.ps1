function Query-Database {

	Param(
		# Database name
		[Parameter(Position = 0, Mandatory = $true)]
		[System.String]
		$dbase,
		# Query to database
		[Parameter(Position = 1, Mandatory = $true)]
		[System.String]
		$qry)
		
	#write-host $dbase
	#write-host $qry
		
	# this holds the results
	$dbase_return = @()
		
	$OpenStatic = 3
	$LockOptimistic = 3
	
	# create connection to database
	$conn = New-Object -ComObject ADODB.Connection
	# create recordset to hold return values
	$rs = New-Object -ComObject ADODB.Recordset
	
	# open connection
	$conn.Open("Provider = Microsoft.Jet.OLEDB.4.0;Data Source=$dbase")
	
	# query
	$rs.Open($qry, $conn, $OpenStatic, $LockOptimistic)
	
	if ( ($qry.split(" ")[0]) -match "SELECT") {
	
		# read from recordset
		while (!$rs.EOF) {
			$model_info = New-Object PSObject
			foreach ($field in $rs.Fields) {
				$model_info | Add-Member -MemberType NoteProperty -Name $($field.Name) -Value $field.Value
			}
			$rs.MoveNext()
			$dbase_return += $model_info
		}
		
		$rs.Close()
		
	} else {
	
		$dbase_return += "Null"
		
	}
	
	$conn.Close()
	
	return $dbase_return
}
	
