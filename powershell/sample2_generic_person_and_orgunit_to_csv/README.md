# sample2_generic_person_and_orgunit_to_csv #

## Formål ##
Dette PowerShell script eksporterer organisationsenheder og personer fra SOFD til separate CSV-filer med henblik på at give et overblik over organisationsstrukturen og medarbejderne.
Scriptet henter data gennem SOFD's OData API og formaterer det til strukturerede CSV-filer. 
For organisationsenheder inkluderes UUID, navn, parent UUID, fulde sti, telefonnummer og adresse.
For personer inkluderes UUID, navn, primær ansættelsesstilling, primær ansættelsesenhed og primær AD-bruger.

## Krav og forudsætninger ##
- PowerShell 5.1 eller nyere
- Netværksadgang
- Gyldig API-nøgle til relevant SOFD med læseadgang
- Modulerne fra shared_modules mappen
	- "logging.psm1" (til logning)
		- "Sofd.psm1" (til at integrere med Sofd)

### Bemærkning til API Nøgler med begrænset læseadgang ###
Såfremt man bruger en API-nøgle med begrænset læseadgang er det nødvendigt med følgende claims:
- ORGUNIT_ADDRESS
- ORGUNIT_PHONE
- PERSON_AFFILIATIONS
- PERSON_USER

## Hvordan scriptet køres ##
1. Sørg for at have en korrekt konfigureret settings.json fil (se eksempel nedenfor)
	- Bemærk afsnit om settings.development.json længere fremme
2. Åbn PowerShell og naviger til script-mappen
3. Kør scriptet: .\sample2_generic_person_and_orgunit_to_csv.ps1

### Konfigurationsfilen ###
Scriptets konfigurationsfil har følgende struktur
```
{
  "Logging":
  {
    "LogFile": "../logs/sample2_generic_person_and_orgunit_to_csv.log",
    "MaxLogLines": "10000"
  },
  "Sofd": 
  {
	"BaseUrl": "https://demo.sofd.io/odata",
	"ApiKey": ""
  },
  "Output":
  {
  	"OutputFolder": "../output",
  	"OutputPersonFileName": "Generic_Persons_Export",
  	"OutputOrgUnitFileName": "Generic_OrgUnits_Export"
  }
}
```
For at scriptet virker er det nødvendigt at udfylde den korrekte sti til jeres sofd og en ApiKey med læseadgang.
Det er muligt at ændre den relative sti for både log og output mappe samt at ændre navnet på output filen.

"OutputOrgUnitFileName" er navnet på CSV filen med OrgUnits og "OutputPersonFileName" er CSV filen med personer.
Disse ligges begge i samme output folder.

#### Outputfilerne i forskellige mapper ####
Kan man bruge de to fileName settings til at ligge relativt fra OutputFolder'en. Bemærk dog, at man ikke skal starte med stien "/", da den allerede implementeres i koden. 

### best practice for developer settings samt log og outputfiler ###
Begge disse er primært relevante, hvis man kører scriptet direkte fra repomappen. Kopier man det over i anden mappe og kører det derfra, så er følgende punkter mindre relevante.

#### Udvikler-indstillinger: ####
Man bør altid oprette en settings.development.json fil til lokale indstillinger og API-nøgler
Scriptet vil automatisk bruge development-indstillinger, hvis filen eksisterer og .gitignore sørger for, at disse ikke ændres ved opdateringer i repo'et og forhindrer eksponering af API-nøgler og personlige konfigurationer i versionsstyring

#### Log- og outputfiler: ####
Log-filer gemmes som standard i ../logs/ mappen
Output CSV-filer gemmes som standard i ../output/ mappen
VIGTIGT: Disse mapper er inkluderet i .gitignore for at forhindre upload af potentiel sensitive data, men også helt lav praktisk, at brugere ikke kommer til at overskrive hinandens log- eller outputfiler.
Det er, som skrevet tidligere, muligt at ændre, hvor både log- og outputfiler gemmes, men ændres dette opfordre vi på det kraftigste til, at de gemmes uden for mappen.