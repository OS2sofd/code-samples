param(
    [parameter(Position=0,Mandatory=$true)][PSCustomObject]$SofdSettings
)

# gets all OrgUnits with primary, secondary and tertiary KLEs
Function Get-SofdOrgUnitKLEs
{
	# fetch OrgUnit with primary, secondary and tertiary KLEs
	$OrgUnitKleQuery = $SofdSettings.BaseUrl + "/OrgUnits?`$expand=KLEPrimary,KLESecondary,KLETertiary"
    $OrgUnitKleResponse = Invoke-RestMethod $OrgUnitKleQuery -Headers @{ApiKey=$SofdSettings.ApiKey}
    
    # takes orgUnit response and enriches each orgUnit with the FullPath parameter
    $OrgUnitWithKLEs = Invoke-EnrichOrgUnitWithFullPath -OrgUnits $OrgUnitKleResponse.value
	
	return $OrgUnitWithKLEs
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

# get all OrgUnits with contact information
Function Get-SofdOrgUnitWithContactInformation
{
	# fetch OrgUnits with contanct information
	$OrgUnitContactQuery = $SofdSettings.BaseUrl + "/OrgUnits?`$expand=phones,addresses"
    $OrgUnitContactResponse = Invoke-RestMethod $OrgUnitContactQuery -Headers @{ApiKey=$SofdSettings.ApiKey}

    # enriches the OrgUnits with the full Path
    $OrgUnitContactInformation = Invoke-EnrichOrgUnitWithFullPath -OrgUnits $OrgUnitContactResponse.value
    
    return $OrgUnitContactInformation
}

# get all people with a primary affiliation and primary ad user
Function Get-SofdPersonWithPrimaryAffiliationAndAd
{
	$PersonWithPrimeAffiliationAndAdQuery = $SofdSettings.BaseUrl + "/Persons?`$expand=affiliations,users&`$filter=(affiliations/any(a: a/Prime eq true)) and (users/any(u: (u/UserType eq 'ACTIVE_DIRECTORY') and (u/Prime eq true)))"
    $PersonWithPrimeAffiliationAndAdResponse = Invoke-RestMethod $PersonWithPrimeAffiliationAndAdQuery -Headers @{ApiKey=$SofdSettings.ApiKey}
    return $PersonWithPrimeAffiliationAndAdResponse.value
}

Export-ModuleMember -function Get-*
