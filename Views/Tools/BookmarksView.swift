import SwiftUI

// MARK: - BookmarksView

struct BookmarksView: View {
    @Bindable var manager: BookmarkManager
    var onSelect: (Bookmark) -> Void

    @State private var showNewFolder = false
    @State private var folderName    = ""
    @State private var selectedFolder: UUID? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // Raíz (sin carpeta)
                Section("Todos") {
                    ForEach(manager.bookmarks(inFolder: nil)) { bm in
                        Button(action: { onSelect(bm) }) {
                            HStack(spacing: 12) {
                                BookmarkIcon()
                                    .stroke(.orange, style: .init(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                                    .frame(width: 18, height: 18)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bm.title).font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary).lineLimit(1)
                                    Text(bm.url.host ?? "").font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(.secondary).lineLimit(1)
                                }
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) { manager.remove(id: bm.id) } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }

                // Carpetas
                ForEach(manager.folders) { folder in
                    Section(folder.name) {
                        ForEach(manager.bookmarks(inFolder: folder.id)) { bm in
                            Button(action: { onSelect(bm) }) {
                                Text(bm.title).font(.system(size: 14, design: .rounded)).lineLimit(1)
                            }
                            .swipeActions {
                                Button(role: .destructive) { manager.remove(id: bm.id) } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Marcadores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showNewFolder = true }) {
                        PlusIcon()
                            .stroke(.blue, style: .init(lineWidth: 2, lineCap: .round))
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .alert("Nueva carpeta", isPresented: $showNewFolder) {
                TextField("Nombre", text: $folderName)
                Button("Crear") {
                    if !folderName.isEmpty { _ = manager.createFolder(name: folderName) }
                    folderName = ""
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}
