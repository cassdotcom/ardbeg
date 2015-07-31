function Get-CensusData 
{
    Param(
        [Parameter()]
        [System.String]
        $varPostCode,
        [Switch]
        $simpl
    )

    # Create queries from postcodes
    $db = "C:\Users\ac00418\Documents\ardbeg\ardbeg-master\db\census.mdb"

    # Output area
    $qry = "SELECT POSTCODE_TO_OA.OUTPUTAREA2011CODE AS OutputArea
            , POSTCODE_TO_OA.POPULATIONCOUNT AS Population
            , POSTCODE_TO_OA.HOUSEHOLDCOUNT AS Households
         FROM POSTCODE_TO_OA 
         WHERE POSTCODE='$varPostCode' "

    Try {
        
        $res = Query-DataBase -database $db -qry $qry

        if ( ! ( $res ) ) {
            
            # no results
            throw "No results from query"
            # NEED MORE ERROR HANDLING

        } else {

            if ( $simpl ) {

                return $res

            } else {

                $varOA = $res.OutputArea

                #region Oa
                $qry = "SELECT OA_TO_HIGHER_AREAS.LAU2011Level2Code AS LAU2
                            , OA_TO_HIGHER_AREAS.Settlement2010Code AS Settlement
                            , OA_TO_HIGHER_AREAS.Locality2010Code AS Locality
                            , OA_TO_HIGHER_AREAS.CouncilArea2011Code AS CouncilArea
                            , OA_TO_HIGHER_AREAS.LocalCharacteristicSector2011Code AS LocalChar
                            , OA_TO_HIGHER_AREAS.DetailedCharacteristicSector2011Code AS DetailedChar
                            , OA_TO_HIGHER_AREAS.PostcodeSector2011 AS POSector
                            , OA_TO_HIGHER_AREAS.CivilParish1930Code AS Parish
                            , OA_TO_HIGHER_AREAS.UKParliamentaryConstituency2005Code AS UKParm
                            , OA_TO_HIGHER_AREAS.ScottishParliamentaryRegion2011Code AS SCParmReg
                            , OA_TO_HIGHER_AREAS.ScottishParliamentaryConstituency2011Code AS SCParmCon
                            , OA_TO_HIGHER_AREAS.ElectoralWard2007Code AS Ward
                            , OA_TO_HIGHER_AREAS.Datazone2001Code AS DataZone
                            , OA_TO_HIGHER_AREAS.IntermediateZone2001Code AS IntZone
                            , OA_TO_HIGHER_AREAS.ScottishIndexofMultipleDeprivation2012Code AS SIMD
                            , OA_TO_HIGHER_AREAS.UrbanRural8Fold2011_12Code AS UrbanRural
                            , OA_TO_HIGHER_AREAS.Easting AS X1
                            , OA_TO_HIGHER_AREAS.Northing AS Y1
                            , OA_TO_HIGHER_AREAS.Hectarage
                            , OA_TO_HIGHER_AREAS.SquareKilometres
                        FROM OA_TO_HIGHER_AREAS
                        WHERE OutputArea2011Code='$varOA' "

                    $AreaDetails = Query-DataBase -database $db -qry $qry
                    #endregion OA

                    $PCArea = New-Object psobject
                    $PCArea | Add-Member -MemberType NoteProperty -Name PostCode -Value $varPostCode

                    #region PARISH
                    $parish = $AreaDetails.Parish
                    $qry = "SELECT CivilParish1930Name FROM CIVILPARISH1930 WHERE CivilParish1930Code=$parish "
                    $p = Query-DataBase -database $db -qry $qry
                    $PCArea | Add-Member -MemberType NoteProperty -Name Parish -Value $p.CivilParish1930Name
                    #endregion PARISH

                    #region COUNCIL
                    $council = $AreaDetails.CouncilArea
                    $qry = "SELECT CouncilArea2011Name FROM COUNCILAREA2011 WHERE CouncilArea2011Code='$council' "
                    $p = Query-DataBase -database $db -qry $qry
                    $PCArea | Add-Member -MemberType NoteProperty -Name Council -Value $p.CouncilArea2011Name
                    #endregion COUNCIL
				
				            #region COUNCIL
                    $locality = $AreaDetails.Locality
                    $qry = "SELECT Locality2010Name FROM LOCALITY2010 WHERE Locality2010Code='$locality' "
                    $p = Query-DataBase -database $db -qry $qry
                    $PCArea | Add-Member -MemberType NoteProperty -Name Locality -Value $p.Locality2010Name
                    #endregion COUNCIL
				
				
				
            }

            return $PCArea
        }

        } Catch {

            $thisError = $_
            Throw "Error"

        }
}
