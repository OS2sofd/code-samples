# sample1_orgunit_kle_to_csv #

## Formål ##
Dette PowerShell script eksporterer organisationsenheder fra SOFD sammen med deres tilknyttede KLE-opmærkninger til en CSV-fil med henblik på at give et overblik over alle opmærkninger.
Scriptet henter data gennem SOFD's OData API og formaterer det til en struktureret CSV-fil, som indeholder organisationsenhedens UUID, navn, fulde sti og alle tilknyttede KLE-opmærkninger med beskrivelser samt markerer, hvis de ikke er aktive.

### Bemærkning til dobbelt notation af ikke-aktive opmærkninger og hvordan ikke-aktive opmærkninger kan ekskluderes###
Scriptet henter også ikke-aktive KLE-opmærkninger og markerer disse som (ikke aktive). Hvis man bruger praksis, at navngive udgået opmærkninger med [udgået] efter deres navn, kan dette resultere i det lidt dobbeltkonfekt-lignende "[udgået] (IKKE Aktive)", men det ene ligger sig til navnet og det andet til status; og på den måde kan der også være et dobbelttjek i det.
Såfremt man ikke ønsker ikke-aktive KLE-opmærkninger skal vises overhovedet, kan man ændre scriptets OdataParameters til:
> "?\`$expand=KLEPrimary(\`$filter=Active eq true),KLESecondary(\`$filter=Active eq true),KLETertiary(\`$filter=Active eq true)"
Denne kan også findes udkommenteret i scriptet. Såfremt denne anvendes, så udkommenter eller slet den nuværende linje

## Krav og forudsætninger ##
- PowerShell 5.1 eller nyere
- Netværksadgang
- Gyldig API-nøgle til relevant SOFD med læseadgang
- Modulerne fra shared_modules mappen
	- "logging.psm1" (til logning)
		- "Sofd.psm1" (til at integrere med Sofd)

### Bemærkning til API Nøgler med begrænset læseadgang ###
Såfremt man bruger en API-nøgle med begrænset læseadgang er det nødvendigt med følgende claims:
- ORGUNIT_KLE

## Hvordan scriptet køres ##
1. Sørg for at have en korrekt konfigureret settings.json fil (se eksempel nedenfor)
	- Bemærk afsnit om settings.development.json længere fremme
2. Åbn PowerShell og naviger til script-mappen
3. Kør scriptet: .\sample1_orgunit_kle_to_csv.ps1

### Konfigurationsfilen ###
Scriptets konfigurationsfil har følgende struktur
```
{
  "Logging":
  {
    "LogFile": "../logs/sample1_orgunit_kle_to_csv.log",
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
  	"OutputFileName": "OrgUnits_KLE_Export"
  }
}
```
For at scriptet virker er det nødvendigt at udfylde den korrekte sti til jeres sofd og en ApiKey med læseadgang.
Det er muligt at ændre den relative sti for både log og output mappe samt at ændre navnet på output filen.

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