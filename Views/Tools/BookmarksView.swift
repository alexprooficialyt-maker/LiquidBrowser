import SwiftUI

// MARK: - BookmarksView (Marcadores y Carpetas Monocromas en Cristal)

public struct BookmarksView: View {
    @State private var bookmarks: [BookmarkItem] = []
    @State private var folders: [BookmarkFolder] = [BookmarkFolder.favoritesFolder]
    @State private var selectedFolderID: UUID? = nil
    @State private var isShowingCreateFolder: Bool = false
    @State private var newFolderName: String = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var onSelectURL: (URL) -> Void

    public init(onSelectURL: @escaping (URL) -> Void) {
        self.onSelectURL = onSelectURL
    }

    private var currentBookmarks: [BookmarkItem] {
        bookmarks.filter { $0.folderID == selectedFolderID }
    }

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                List {
                    if selectedFolderID == nil {
                        // Sección de Carpetas
                        Section("Carpetas") {
                            ForEach(folders) { folder in
                                Button(action: {
                                    HapticManager.shared.touchLight()
                                    selectedFolderID = folder.id
                                }) {
                                    HStack(spacing: 12) {
                                        let iconType = LiquidIconType(rawValue: folder.iconTypeRaw) ?? .spaceFolder
                                        LiquidIconView(iconType, size: 16, color: theme.textPrimary(for: colorScheme))

                                        Text(folder.name)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textPrimary(for: colorScheme))

                                        Spacer()

                                        LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: colorScheme))
                                    }
                                }
                                .listRowBackground(theme.cardBackground(for: colorScheme))
                            }
                        }
                    } else {
                        // Navegación hacia atrás dentro de carpeta
                        Section {
                            Button(action: {
                                HapticManager.shared.touchLight()
                                selectedFolderID = nil
                            }) {
                                HStack(spacing: 8) {
                                    LiquidIconView(.chevronLeft, size: 12)
                                    Text("Todas las carpetas")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                }
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                            }
                        }
                        .listRowBackground(theme.cardBackground(for: colorScheme))
                    }

                    // Sección de Marcadores
                    Section(selectedFolderID == nil ? "Marcadores principales" : "En esta carpeta") {
                        if currentBookmarks.isEmpty {
                            Text("No hay marcadores guardados")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(theme.textTertiary(for: colorScheme))
                                .listRowBackground(theme.cardBackground(for: colorScheme))
                        } else {
                            ForEach(currentBookmarks) { item in
                                Button(action: {
                                    HapticManager.shared.touchMedium()
                                    dismiss()
                                    onSelectURL(item.url)
                                }) {
                                    HStack(spacing: 12) {
                                        LiquidIconView(.bookmark, size: 16, color: theme.textPrimary(for: colorScheme))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.displayTitle)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                                                .lineLimit(1)

                                            Text(item.url.host ?? item.url.absoluteString)
                                                .font(.system(size: 12, design: .rounded))
                                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                                                .lineLimit(1)
                                        }

                                        Spacer()
                                    }
                                    .padding(.vertical, 2)
                                }
                                .listRowBackground(theme.cardBackground(for: colorScheme))
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteBookmark(item)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Marcadores")
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

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        HapticManager.shared.touchLight()
                        isShowingCreateFolder = true
                    }) {
                        LiquidIconView(.newTab, size: 14)
                    }
                }
            }
            .alert("Nueva Carpeta", isPresented: $isShowingCreateFolder) {
                TextField("Nombre de carpeta", text: $newFolderName)
                Button("Crear") {
                    createFolder()
                }
                Button("Cancelar", role: .cancel) {
                    newFolderName = ""
                }
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        if let storedFolders: [BookmarkFolder] = StorageEngine.shared.loadJSON(from: "bookmark_folders.json") {
            self.folders = storedFolders
        }
        if let storedBookmarks: [BookmarkItem] = StorageEngine.shared.loadJSON(from: "bookmarks.json") {
            self.bookmarks = storedBookmarks
        }
    }

    private func createFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newFolder = BookmarkFolder(name: trimmed, orderIndex: folders.count)
        folders.append(newFolder)
        StorageEngine.shared.saveJSON(folders, to: "bookmark_folders.json")
        newFolderName = ""
        HapticManager.shared.notifySuccess()
    }

    private func deleteBookmark(_ item: BookmarkItem) {
        bookmarks.removeAll { $0.id == item.id }
        StorageEngine.shared.saveJSON(bookmarks, to: "bookmarks.json")
        HapticManager.shared.touchLight()
    }
}
