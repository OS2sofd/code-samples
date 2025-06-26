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
	    $OrgUnitWithKLEs = Get-SofdOrgUnitKLEs
	    $CsvData = @()
	    Foreach($OrgUnit in $OrgUnitWithKLEs)
	    {
			$KLEString = ""            
            Foreach($KLE in $OrgUnit.KLEPrimary)
            {
				$KLEString += $KLE.Code + ": " + $KLE.Name
				if ($KLE.Active -eq $False)
				{
					$KLEString += " (IKKE Aktive)"
				}
				$KLEString += "; "  
			}
            
            Foreach($KLE in $OrgUnit.KLESecondary)
            {
				$KLEString += $KLE.Code + ": " + $KLE.Name
				if ($KLE.Active -eq $False)
				{
					$KLEString += " (IKKE Aktive)"
				}
				$KLEString += "; "  
			}
            
            Foreach($KLE in $OrgUnit.KLETertiary)
            {
				$KLEString += $KLE.Code + ": " + $KLE.Name
				if ($KLE.Active -eq $False)
				{
					$KLEString += " (IKKE Aktive)"
				}
				$KLEString += "; "  
			}
            
            $CsvRow = [PSCustomObject]@{
                Uuid = $OrgUnit.Uuid
                Navn = $OrgUnit.Name
                "Fulde sti" = $OrgUnit.FullPath
                "KLE (Aktive medmindre andet anført)" = $KLEString
            }
            
        	$CsvData += $CsvRow
       		
		}
		$CsvPath = "$($ScriptPath.Directory.FullName)/$($Settings.Output.OutputFolder)/$($Settings.Output.OutputFileName).csv"
        $CsvData | Export-Csv -Path $CsvPath -Encoding UTF8 -Delimiter ";" -NoTypeInformation
        
        LogInfo("CSV file created: $CsvPath with $($CsvData.Count) records")
	}
    Catch
    {
        LogException($_)
    }
}
LogInfo("Finished executing $ScriptPath in $([math]::round($ScriptTimer.TotalSeconds,1)) seconds")
ShrinkLog
#endregion