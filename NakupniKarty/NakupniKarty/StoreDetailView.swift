import SwiftUI
import PhotosUI

struct StoreDetailView: View {
    let store: Store

    @State private var customCard: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var showResetConfirm = false

    /// Vlastní karta se ukládá do Documents jako `<id>_card.jpg`.
    private var customCardURL: URL {
        URL.documentsDirectory.appendingPathComponent("\(store.id)_card.jpg")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                cardImage

                if customCard == nil {
                    PhotosPicker(selection: $pickerItem,
                                  matching: .images,
                                  photoLibrary: .shared()) {
                        actionLabel("Nahradit vlastní kartou",
                                    systemImage: "photo.on.rectangle")
                    }
                } else {
                    Button {
                        showResetConfirm = true
                    } label: {
                        actionLabel("Obnovit defaultní kartu",
                                    systemImage: "arrow.counterclockwise")
                    }
                    .confirmationDialog("Opravdu chcete obnovit defaultní kartu?",
                                         isPresented: $showResetConfirm,
                                         titleVisibility: .visible) {
                        Button("Ano", role: .destructive) { resetCard() }
                        Button("Ne", role: .cancel) {}
                    }
                }

                if let pageURL = store.pageURL {
                    Link(destination: pageURL) {
                        actionLabel("Otevřít aktuální verzi na webu",
                                    systemImage: "safari")
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadCustomCardFromDisk)
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task { await importCustomCard(from: newItem) }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var cardImage: some View {
        let displayed: Image? = {
            if let ui = customCard { return Image(uiImage: ui) }
            return Image(bundleFile: store.card)
        }()

        if let img = displayed {
            img
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .allowsHitTesting(false) // žádné gesto → scroll proletí
        } else {
            ContentUnavailableView("Obrázek karty se nenačetl",
                                    systemImage: "photo")
        }
    }

    private func actionLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Persistence

    private func loadCustomCardFromDisk() {
        guard let data = try? Data(contentsOf: customCardURL),
              let img = UIImage(data: data) else { return }
        customCard = img
    }

    private func importCustomCard(from item: PhotosPickerItem) async {
        defer { Task { @MainActor in pickerItem = nil } }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let img = UIImage(data: data) else { return }
        // Přeuložit jako JPEG (sjednotí HEIC z fotek, menší file).
        guard let jpeg = img.jpegData(compressionQuality: 0.9) else { return }
        try? jpeg.write(to: customCardURL, options: .atomic)
        await MainActor.run { customCard = img }
    }

    private func resetCard() {
        try? FileManager.default.removeItem(at: customCardURL)
        customCard = nil
    }
}

