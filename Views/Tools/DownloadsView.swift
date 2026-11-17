import SwiftUI

// MARK: - DownloadsView

struct DownloadsView: View {
    @Bindable var manager: DownloadManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Group {
                if manager.downloads.isEmpty {
                    VStack(spacing: 16) {
                        DownloadIcon()
                            .stroke(.secondary, style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 48, height: 48)
                        Text("No hay descargas")
                            .font(.system(size: 17, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(manager.downloads) { dl in
                            DownloadRow(download: dl) { manager.remove(id: dl.id) }
                        }
                    }
                }
            }
            .navigationTitle("Descargas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } }
            }
        }
    }
}

// MARK: - DownloadRow

struct DownloadRow: View {
    let download: Download
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(download.filename)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .lineLimit(1)
                Spacer()
                stateLabel
            }

            if case .downloading = download.state {
                ProgressView(value: download.progress)
                    .tint(.blue)
                Text("\(Int(download.progress * 100))% — \(download.formattedSize)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            if case .completed = download.state, let url = download.localURL {
                ShareLink(item: url) {
                    Label("Abrir / Compartir", systemImage: "square.and.arrow.up")
                        .font(.system(size: 12, design: .rounded))
                }
            }

            if case .failed(let msg) = download.state {
                Text("Error: \(msg)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(AppColors.danger)
            }
        }
        .padding(.vertical, 4)
        .swipeActions {
            Button(role: .destructive, action: onRemove) {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private var stateLabel: some View {
        switch download.state {
        case .pending:
            Text("Esperando").font(.system(size: 11, design: .rounded)).foregroundStyle(.secondary)
        case .downloading:
            Text("Descargando").font(.system(size: 11, design: .rounded)).foregroundStyle(.blue)
        case .paused:
            Text("Pausado").font(.system(size: 11, design: .rounded)).foregroundStyle(.orange)
        case .completed:
            Text("Completado").font(.system(size: 11, design: .rounded)).foregroundStyle(AppColors.secure)
        case .failed:
            Text("Error").font(.system(size: 11, design: .rounded)).foregroundStyle(AppColors.danger)
        }
    }
}
