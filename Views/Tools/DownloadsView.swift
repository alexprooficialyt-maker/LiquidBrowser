import SwiftUI

// MARK: - DownloadsView (Monochrome Liquid Glass)

public struct DownloadsView: View {
    @State private var downloads: [DownloadItem] = []
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var sharingURL: URL? = nil

    public init() {}

    public var body: some View {
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                if downloads.isEmpty {
                    emptyDownloadsView
                } else {
                    downloadsListView
                }
            }
            .navigationTitle("Descargas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        HapticManager.shared.touchLight()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                }

                if !downloads.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Limpiar") {
                            HapticManager.shared.touchMedium()
                            clearCompleted()
                        }
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                }
            }
        }
        .onAppear {
            loadDownloads()
        }
        .sheet(item: Binding<IdentifiableURL?>(
            get: { sharingURL.map { IdentifiableURL(url: $0) } },
            set: { sharingURL = $0?.url }
        )) { item in
            ActivityShareSheet(activityItems: [item.url])
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var emptyDownloadsView: some View {
        let theme = ThemeEngine.shared

        VStack(spacing: 16) {
            LiquidIconView(.download, size: 48, color: theme.textSecondary(for: colorScheme).opacity(0.6))

            Text("Sin descargas recientes")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Text("Los archivos descargados aparecerán aquí con su estado y tamaño.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    private var downloadsListView: some View {
        let theme = ThemeEngine.shared

        List {
            ForEach(downloads) { item in
                downloadRow(for: item)
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(theme.specularBorder(for: colorScheme))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func downloadRow(for item: DownloadItem) -> some View {
        let theme = ThemeEngine.shared

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(theme.cardBackground(for: colorScheme))
                        .frame(width: 40, height: 40)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                        }

                    LiquidIconView(.download, size: 20, color: theme.textPrimary(for: colorScheme))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.suggestedFileName)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(item.formattedSize)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        stateBadge(for: item.state)
                    }
                }

                Spacer()

                if case .completed(let path) = item.state {
                    Button(action: {
                        HapticManager.shared.touchLight()
                        let fileURL = StorageEngine.shared.downloadsDirectory.appendingPathComponent(path)
                        sharingURL = fileURL
                    }) {
                        LiquidIconView(.share, size: 16, color: theme.textPrimary(for: colorScheme))
                            .padding(8)
                            .background(theme.cardBackground(for: colorScheme))
                            .clipShape(Circle())
                            .overlay {
                                Circle().strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                            }
                    }
                }
            }

            if case .downloading(let progress) = item.state {
                ProgressView(value: progress)
                    .tint(theme.textPrimary(for: colorScheme))
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
    }

    private func stateText(for state: DownloadState) -> String {
        switch state {
        case .queued:
            return "En cola"
        case .downloading(let p):
            return "\(Int(p * 100))%"
        case .paused:
            return "En pausa"
        case .completed:
            return "Completado"
        case .failed:
            return "Error"
        }
    }

    private func stateBadge(for state: DownloadState) -> some View {
        let theme = ThemeEngine.shared
        return Text(stateText(for: state))
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(theme.textSecondary(for: colorScheme))
    }

    // MARK: - Actions

    private func loadDownloads() {
        if let stored: [DownloadItem] = StorageEngine.shared.loadJSON(from: "downloads.json") {
            self.downloads = stored
        }
    }

    private func deleteItem(_ item: DownloadItem) {
        HapticManager.shared.touchLight()
        downloads.removeAll { $0.id == item.id }
        StorageEngine.shared.saveJSON(downloads, to: "downloads.json")

        if case .completed(let relPath) = item.state {
            let fileURL = StorageEngine.shared.downloadsDirectory.appendingPathComponent(relPath)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    private func clearCompleted() {
        downloads.removeAll { $0.state.isTerminal }
        StorageEngine.shared.saveJSON(downloads, to: "downloads.json")
    }
}

// MARK: - IdentifiableURL Helper

public struct IdentifiableURL: Identifiable {
    public let id = UUID()
    public let url: URL
}

// MARK: - ActivityShareSheet

public struct ActivityShareSheet: UIViewControllerRepresentable {
    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]? = nil

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
