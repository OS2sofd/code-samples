param(
    [parameter(Position=0,Mandatory=$true)][PSCustomObject]$SofdSettings
)

#fetches OrgUnits from Sofd with optional parameters to add futher OdataParameters and enrich the OrgUnit with FullPath
Function Get-SofdOrgUnits
{
	Param($OdataParameters = "", $EnrichWithFullPath = $false)
	
	# fetches OrgUnits from Sofd (with possibility to add futher parameters)
	$OrgUnitQuery = $SofdSettings.BaseUrl + "/OrgUnits" + $OdataParameters
    $OrgUnitResponse = Invoke-RestMethod $OrgUnitQuery -Headers @{ApiKey=$SofdSettings.ApiKey}
	
	#if optional parameter set to true, it will enrich the orgUnit a FullPath string (format: Grandparent/Parent/OrgUnit)
	if($EnrichWithFullPath)
	{
		$OrgUnits = Invoke-EnrichOrgUnitWithFullPath -OrgUnits $OrgUnitResponse.value
		return $OrgUnits 
	}
	
	return $OrgUnitResponse.value
}

#fetches Persons from Sofd with optional parameters to add futher OdataParameters
Function Get-SofdPersons
{
	Param($OdataParameters = "")
	
	# fetches Persons from Sofd (with possibility to add futher parameters)
	$PersonQuery = $SofdSettings.BaseUrl + "/Persons" + $OdataParameters
    $PersonResponse = Invoke-RestMethod $PersonQuery -Headers @{ApiKey=$SofdSettings.ApiKey}
	return $PersonResponse.value
}

# this function insert to FullPath into a list of OrgUnits without futher rest calls
Function Invoke-EnrichOrgUnitWithFullPath
{
	Param($OrgUnits)
	
	# creates an overview for quicker seach
	$OrgUnitOverview = @{}
    foreach ($OrgUnit in $OrgUnits)
    {
        $OrgUnitOverview[$OrgUnit.Uuid] = $OrgUnit
    }
	
	# insert the FullPath Parameter with Read-ParentPath the recursive helper-function
	Foreach($OrgUnit in $OrgUnits)
    {
		$ParentalPath = Read-ParentPath -AllOrgUnits $OrgUnitOverview -CurrentOrgUnit $OrgUnit -ParentalPath ""
		$OrgUnit | Add-Member -MemberType NoteProperty -Name "FullPath" -Value ($ParentalPath + $OrgUnit.Name)
	} 
	
	return $OrgUnits
}

# this function are a helper function to Invoke-EnrichOrgUnitWithFullPath which allows the function
# to recursively look for parent and add it to the full path
Function Read-ParentPath
{
	Param($AllOrgUnits, $CurrentOrgUnit, [string] $ParentalPath)
	if($CurrentOrgUnit.ParentUuid -and $CurrentOrgUnit.ParentUuid -ne "")
	{
		Try
		{
			if ($AllOrgUnits.ContainsKey($CurrentOrgUnit.ParentUuid))
			{
				$Parent = $AllOrgUnits[$CurrentOrgUnit.ParentUuid]
				$ParentalPath = Read-ParentPath -AllOrgUnits $AllOrgUnits -CurrentOrgUnit $Parent -ParentalPath ($Parent.Name + "\" + $ParentalPath)
			}
			else
			{
				LogInfo("Could find parent with Uuid: " + $CurrentOrgUnit.ParentUuid)
			}
		}
		Catch
		{
			LogException($_)
		}
		
	}
	return $ParentalPath
}

Export-ModuleMember -function Get-*
