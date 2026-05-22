# Nákupní karty

Nativní iOS appka, která zpřístupní věrnostní karty obchodů z webu
[nakupniaplikace.cz](https://nakupniaplikace.cz/) offline – v jedné appce,
bez registrace.

## Funkce

- **Grid obchodů** – 3 na řádek, loga, abecedně řazeno (česká lokalizace).
- **Vyhledávání** – živý filtr při psaní, case- i diakritika-insensitive.
- **Detail karty** – obrázek věrnostní karty zabalený lokálně v appce,
  funguje plně offline.
- **Vlastní karta** – uživatel si může nahradit defaultní kartu vlastní
  fotkou z Fotek (uloží se lokálně do `Documents/`); kdykoliv lze obnovit
  defaultní kartu.
- **Fallback na web** – tlačítko *Otevřít aktuální verzi na webu* otevře
  subpage obchodu, kdyby obchod kartu na webu aktualizoval.

## Struktura

```
NakupniKarty/              Xcode projekt (SwiftUI, iOS 17+)
  NakupniKarty/
    NakupniKartyApp.swift  vstupní bod
    ContentView.swift      grid + vyhledávání
    StoreDetailView.swift  detail karty + vlastní karta
    Store.swift            model + loader stores.json
    Resources/
      stores.json          manifest obchodů
      img/                 loga + obrázky karet (64 souborů)
    Assets.xcassets/       app icon
scrape/
  scrape.py                scraper dat z nakupniaplikace.cz
```

## Build

Otevři `NakupniKarty/NakupniKarty.xcodeproj` v Xcode (16+) a spusť (`Cmd+R`).
Projekt používá synchronizovanou složku, takže nově přidané obrázky/soubory
se přibalí automaticky.

## Aktualizace dat

Kdyby web aktualizoval loga nebo obrázky karet:

```sh
cd scrape
python3 scrape.py
```

Skript znovu stáhne loga i karty všech obchodů do
`NakupniKarty/NakupniKarty/Resources/` a přepíše `stores.json`.

## Data

Loga a obrázky věrnostních karet pocházejí z [nakupniaplikace.cz](https://nakupniaplikace.cz/).
