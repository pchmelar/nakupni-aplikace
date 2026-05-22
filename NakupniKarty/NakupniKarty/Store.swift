import SwiftUI

/// Jeden obchod načtený z Resources/stores.json (scrapnuto z nakupniaplikace.cz).
struct Store: Identifiable, Decodable {
    let id: String
    let name: String
    let logo: String   // název souboru, např. "kaufland_logo.jpg"
    let card: String   // název souboru, např. "kaufland_card.jpg"
    let url: String     // fallback subpage na webu

    var pageURL: URL? { URL(string: url) }
}

enum StoreLoader {
    /// Načte a dekóduje stores.json zabalený v appce.
    static func load() -> [Store] {
        guard let url = Bundle.main.url(forResource: "stores", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let stores = try? JSONDecoder().decode([Store].self, from: data)
        else {
            assertionFailure("stores.json se nepodařilo načíst z bundle")
            return []
        }
        // Abecedně podle českého řazení (Č za C, Š za S atd.).
        return stores.sorted {
            $0.name.compare($1.name, options: [], range: nil, locale: Locale(identifier: "cs_CZ"))
                == .orderedAscending
        }
    }
}

extension Image {
    /// Obrázek zabalený jako loose resource (img složka se v bundlu zploští).
    /// Hledá podle jména souboru i s příponou (.jpg / .jpeg).
    init?(bundleFile filename: String) {
        let base = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: base, withExtension: ext),
              let ui = UIImage(contentsOfFile: url.path)
        else { return nil }
        self = Image(uiImage: ui)
    }
}
