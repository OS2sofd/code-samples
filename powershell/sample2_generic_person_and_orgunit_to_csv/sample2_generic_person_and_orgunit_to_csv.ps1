[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Settings
$ScriptPath = Get-Item $MyInvocation.MyCommand.Path
$Settings = Get-Content -Encoding UTF8 -Path "$($ScriptPath).settings.json" | ConvertFrom-Json
if( Test-Path "$($ScriptPath).settings.development.json" )
{
    $Settings = Get-Content -Encoding UTF8 -Path "$($ScriptPath).settings.development.json" | ConvertFrom-Json
}
#endregion

#region Imports
Import-Module -Name "$($ScriptPath.Directory.FullName)/../shared_modules/logging.psm1" -ArgumentList ($Settings.Logging.LogFile, $Settings.Logging.MaxLogLines) -Force
Import-Module -Name "$($ScriptPath.Directory.FullName)/../shared_modules/Sofd.psm1" -ArgumentList ($Settings.Sofd) -Force -DisableNameChecking
#endregion

#region Main
LogInfo("Executing $ScriptPath")
$ScriptTimer = Measure-Command {
    Try
    {
		LogInfo("Fetching data from SOFD")
		$OrgUnitWithContactInfo = Get-SofdOrgUnitWithContactInformation
		$PersonWithPrimaryAffiliationAndAd = Get-SofdPersonWithPrimaryAffiliationAndAd
		
		# arrays for OrgUnits and Persons csvs respectively 
		$OrgUnitCsvData = @()
		$PersonCsvData = @()
		
		# creates an array overview for optimizing search
		$OrgUnitOverview = @{}
		
		Foreach($OrgUnit in $OrgUnitWithContactInfo)
		{
			# creates empty string and fills it, if the OrgUnit have any primary phone/addresses
			$PhoneString = ""
			$PrimaryPhones = $OrgUnit.Phones | Where-Object { $_.Prime -eq $true }
			if ($PrimaryPhones.Count -gt 0)
			{
				$PhoneString = $PrimaryPhones[0].PhoneNumber
			}
    		
    		$AddressString = ""
    		$PrimaryAddresses = $OrgUnit.Addresses | Where-Object { $_.Prime -eq $true }
    		if ($PrimaryAddresses.Count -gt 0)
    		{
				$AddressString = $PrimaryAddresses[0].Street + ", " + $PrimaryAddresses[0].PostalCode + " " + $PrimaryAddresses[0].City
			}
    		
			# creates csv row
			$CsvRow = [PSCustomObject]@{
                Uuid = $OrgUnit.Uuid
                Navn = $OrgUnit.Name
                "Parent uuid" = $OrgUnit.ParentUuid
                "Fulde sti" = $OrgUnit.FullPath
                Telefonnummer = $PhoneString
                Adresse = $AddressString
            }
            
        	$OrgUnitCsvData += $CsvRow
        	
        	# populates the overview array
        	$OrgUnitOverview[$OrgUnit.Uuid] = $OrgUnit
		}
		
		Foreach($Person in $PersonWithPrimaryAffiliationAndAd)
		{
			# finds the name of the primary employment or sets it to the Uuid
			$PrimaryEmploymentName = ""
			if ($OrgUnitOverview.ContainsKey($Person.Affiliations[0].OrgunitUuid))
            {
				$PrimaryEmploymentName = $OrgUnitOverview[$Person.Affiliations[0].OrgunitUuid].Name
			}
			else
			{
				$PrimaryEmploymentName = $Person.Affiliations[0].OrgunitUuid
			}
			
			#creates the csv row
			$CsvRow = [PSCustomObject]@{
                Uuid = $Person.Uuid
                Fornavn = $Person.Firstname
                Efternavn = $Person.Surname
                "Primære Ansættelses stilling" = $Person.Affiliations[0].PositionName
                "Primære Ansættelses enhed" = $PrimaryEmploymentName
                "Primære AD bruger" = $Person.Users[0].UserId
            }
            
        	$PersonCsvData += $CsvRow
		}
		
		# exports arrays to separate csv files
		$OrgUnitCsvPath = "$($ScriptPath.Directory.FullName)/$($Settings.Output.OutputFolder)/$($Settings.Output.OutputOrgUnitFileName).csv"
		$PersonCsvPath = "$($ScriptPath.Directory.FullName)/$($Settings.Output.OutputFolder)/$($Settings.Output.OutputPersonFileName).csv"
		$OrgUnitCsvData | Export-Csv -Path $OrgUnitCsvPath -Encoding UTF8 -Delimiter ";" -NoTypeInformation
		$PersonCsvData | Export-Csv -Path $PersonCsvPath -Encoding UTF8 -Delimiter ";" -NoTypeInformation
        
		LogInfo("Generic CSV file created wtih $($OrgUnitCsvData.Count) OrgUnit records; $($PersonCsvData.Count) Person records; to a total of $($OrgUnitCsvData.Count + $PersonCsvData.Count)")
	}
    Catch
    {
        LogException($_)
    }
}
LogInfo("Finished executing $ScriptPath in $([math]::round($ScriptTimer.TotalSeconds,1)) seconds")
ShrinkLog
#endregion