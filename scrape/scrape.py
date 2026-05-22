#!/usr/bin/env python3
"""Scraper pro nakupniaplikace.cz.

Stáhne loga a obrázky věrnostních karet všech obchodů a uloží je do
../NakupniKarty/NakupniKarty/Resources/ (img/ + stores.json), odkud si je
bere iOS appka. Spusť znovu, kdykoliv web aktualizuje karty:

    python3 scrape.py
"""
import json
import os
import re
import subprocess

BASE = "https://nakupniaplikace.cz/"
RES = "../NakupniKarty/NakupniKarty/Resources"
UA = "Mozilla/5.0"

# (detailní stránka, zobrazený název) – pořadí jako na webu, appka řadí abecedně.
STORES = [
    ("kaufland.html", "Kaufland"), ("albert.php", "Albert"),
    ("clubcardtesco.html", "Tesco Clubcard"), ("lidl.html", "Lidl Plus"),
    ("penny.html", "Penny Market"), ("globus.html", "Globus"),
    ("dm.html", "dm drogerie"), ("teta.html", "Teta"),
    ("orlen.html", "Orlen Benzina"), ("ikea.html", "IKEA"),
    ("tescoma.html", "Tescoma"), ("billa.html", "Billa"),
    ("mobelix.html", "Möbelix"), ("kik.html", "KiK"),
    ("bambule.html", "Bambule"), ("benu.html", "BENU Lékárna"),
    ("drmax.html", "Dr. Max"), ("action.html", "Action"),
    ("Terranova.html", "Terranova"), ("rossmann.html", "Rossmann"),
    ("mol.html", "MOL"), ("tchibo.html", "Tchibo"),
    ("coop.html", "COOP"), ("pompo.html", "Pompo"),
    ("decathlon.html", "Decathlon"), ("obi.html", "OBI"),
    ("jip.html", "JIP"), ("canda.html", "C&A"),
    ("luxor.html", "Luxor"), ("sparkys.html", "Sparkys"),
    ("baumaxcz.html", "bauMax"), ("superzoo.html", "Super zoo"),
]


def fetch(path):
    """Stáhne stránku a vrátí HTML jako text."""
    r = subprocess.run(["curl", "-s", "-A", UA, BASE + path],
                       capture_output=True, text=True, check=True)
    return r.stdout


def download(url_path, dest):
    """Stáhne binární soubor (obrázek)."""
    subprocess.run(["curl", "-s", "-A", UA, "-o", dest, BASE + url_path],
                   check=True)


def main():
    os.makedirs(f"{RES}/img", exist_ok=True)

    # Logo gridu z homepage – mapuje detailní stránku -> cestu k logu.
    home = fetch("")
    logos = {}
    for m in re.finditer(
            r'href="([a-zA-Z&.]+\.(?:html|php))"[^>]*>\s*<img[^>]+src="(obrazky/[^"]+)"',
            home):
        logos.setdefault(m.group(1), m.group(2))

    manifest = []
    for page, name in STORES:
        sid = page.split(".")[0].lower()
        html = fetch(page)
        # Obrázek karty = první <img> na detailní stránce.
        imgs = re.findall(r'<img[^>]+src="(obrazky/[^"]+)"', html)
        if not imgs:
            print(f"  ! {name}: nenalezen obrázek karty")
            continue
        card_src, logo_src = imgs[0], logos.get(page)

        logo_file = sid + "_logo" + os.path.splitext(logo_src)[1]
        card_file = sid + "_card" + os.path.splitext(card_src)[1]
        download(logo_src, f"{RES}/img/{logo_file}")
        download(card_src, f"{RES}/img/{card_file}")

        manifest.append({"id": sid, "name": name, "logo": logo_file,
                         "card": card_file, "url": BASE + page})
        print(f"  ✓ {name}")

    with open(f"{RES}/stores.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    print(f"\nHotovo: {len(manifest)} obchodů -> {RES}/stores.json")


if __name__ == "__main__":
    main()
