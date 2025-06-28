# OS2sofd Code Samples

Dette repository indeholder kodeeksempler, der demonstrerer brugen af [OS2sofd APIer](https://www.sofd.io/documentation/SOFD%20Core%20-%20API%20beskrivelse.pdf) til forskellige forretningsformål. Eksemplerne er målrettet udviklere og teknikere, der ønsker at integrere med eller automatisere processer baseret på OS2sofd.

## Status

Første eksempler er lavet i **PowerShell**. Support for andre sprog som Python, C#, mv. kan tilføjes senere.

## Formål

Formålet med repositoryet er at:

- Give konkrete eksempler på anvendelse af OS2sofd API
- Inspirere til automatisering og integration i lokale systemer
- Vise best practices for kald, autentificering og datastruktur

## Struktur (planlagt)

```text
/
├── powershell/                                     # PowerShell-eksempler
│   └── /shared_modules/                            # Delte Powershell moduler
│   └── /sample1_orgunit_kle_to_csv/                # Eksempel til udtræk af enheder med KLE-opmærkning
│   └── /sample2_generic_person_and_orgunit_to_csv  # Generisk eksempel til udtræk af enheder og personer
├── python/                                         # Python-eksempler
├── LICENSE                                         # Mozilla Public License 2.0
└── README.md                                       # Dette dokument
```

## Brug
Når eksemplerne er tilgængelige, vil hver undermappe indeholde sin egen README med:

* Hvilket formål scriptet løser
* Krav og forudsætninger
* Hvordan man kører det

## Bidrag
Pull requests er meget velkomne — uanset om du vil tilføje nye eksempler, forbedre eksisterende eller foreslå ændringer til strukturen.
Hvis du har idéer til relevante scenarier, men ikke selv vil kode dem, er du også velkommen til at oprette en issue.

## Licens
Dette projekt er licenseret under Mozilla Public License 2.0. Se LICENSE for detaljer.
