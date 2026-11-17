import SwiftUI

// MARK: - DownloadsView (Gestor de Descargas Monocromo en Cristal)

public struct DownloadsView: View {
    @State private var downloadManager = DownloadManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var sharingURL: URL? = nil

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                if downloadManager.downloads.isEmpty {
                    emptyDownloadsView(theme: theme)
                } else {
                    downloadsListView(theme: theme)
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

                if !downloadManager.downloads.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Limpiar") {
                            HapticManager.shared.touchMedium()
                            clearFinishedDownloads()
                        }
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                }
            }
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
    private func emptyDownloadsView(theme: ThemeManager) -> some View {
        VStack(spacing: 16) {
            LiquidIconView(.download, size: 48, color: theme.textSecondary(for: colorScheme).opacity(0.6))

            Text("Sin descargas recientes")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Text("Los archivos descargados aparecerán aquí con su estado, tamaño y opciones de guardado.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    private func downloadsListView(theme: ThemeManager) -> some View {
        List {
            ForEach(downloadManager.downloads) { item in
                downloadRow(for: item, theme: theme)
                    .listRowBackground(theme.cardBackground(for: colorScheme))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            downloadManager.cancelDownload(id: item.id)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
        }
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func downloadRow(for item: DownloadItem, theme: ThemeManager) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.surfaceElevated(for: colorScheme))
                        .frame(width: 44, height: 44)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                            .foregroundStyle(theme.textTertiary(for: colorScheme))

                        Text(stateText(for: item.state))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                }

                Spacer()

                // Acción según el estado
                switch item.state {
                case .completed(let path):
                    Button(action: {
                        HapticManager.shared.touchLight()
                        let fileURL = StorageEngine.shared.downloadsDirectory.appendingPathComponent(path)
                        sharingURL = fileURL
                    }) {
                        LiquidIconView(.share, size: 16, color: theme.textPrimary(for: colorScheme))
                            .padding(8)
                            .background(theme.surfaceElevated(for: colorScheme))
                            .clipShape(Circle())
                    }
                case .downloading:
                    Button(action: {
                        downloadManager.pauseDownload(id: item.id)
                    }) {
                        LiquidIconView(.stop, size: 14, color: theme.textSecondary(for: colorScheme))
                            .padding(8)
                    }
                case .paused:
                    Button(action: {
                        downloadManager.resumeDownload(id: item.id)
                    }) {
                        LiquidIconView(.renewTab, size: 14, color: theme.textPrimary(for: colorScheme))
                            .padding(8)
                    }
                default:
                    EmptyView()
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
        case .failed(let err):
            return "Error: \(err)"
        }
    }

    private func clearFinishedDownloads() {
        downloadManager.downloads.removeAll { $0.state.isTerminal }
        downloadManager.saveDownloads()
    }
}

// MARK: - IdentifiableURL

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
