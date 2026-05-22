import SwiftUI

struct ContentView: View {
    private let stores = StoreLoader.load()
    @State private var search = ""

    // 3 obchody na řádek
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    /// `localizedStandardContains` je case- i diacritic-insensitive a respektuje locale,
    /// takže „pen" matchne „Penny", „cand" matchne „C&A" atd.
    private var filteredStores: [Store] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return stores }
        return stores.filter { $0.name.localizedStandardContains(q) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if filteredStores.isEmpty {
                    ContentUnavailableView.search(text: search)
                        .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredStores) { store in
                            NavigationLink(value: store.id) {
                                StoreCell(store: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
            }
            .navigationTitle("Nákupní karty")
            .searchable(text: $search,
                         placement: .navigationBarDrawer(displayMode: .always),
                         prompt: "Hledat obchod")
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .navigationDestination(for: String.self) { id in
                if let store = stores.first(where: { $0.id == id }) {
                    StoreDetailView(store: store)
                }
            }
        }
    }
}

private struct StoreCell: View {
    let store: Store

    var body: some View {
        VStack(spacing: 6) {
            Group {
                if let img = Image(bundleFile: store.logo) {
                    img.resizable().scaledToFit()
                } else {
                    Color(.secondarySystemBackground)
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(store.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(.primary)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ContentView()
}
