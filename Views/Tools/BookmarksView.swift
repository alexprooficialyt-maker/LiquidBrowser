import SwiftUI

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
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                List {
                    if selectedFolderID == nil {
                        Section("Carpetas") {
                            ForEach(folders) { folder in
                                Button(action: {
                                    HapticManager.shared.touchLight()
                                    selectedFolderID = folder.id
                                }) {
                                    HStack(spacing: 12) {
                                        LiquidIconView(.spaceFolder, size: 16, color: theme.textPrimary(for: colorScheme))
                                        Text(folder.name)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                                        Spacer()
                                        LiquidIconView(.forward, size: 12, color: theme.textSecondary(for: colorScheme))
                                    }
                                }
                            }
                        }
                    } else {
                        Section {
                            Button(action: {
                                HapticManager.shared.touchLight()
                                selectedFolderID = nil
                            }) {
                                HStack(spacing: 8) {
                                    LiquidIconView(.back, size: 12)
                                    Text("Todas las carpetas")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                }
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                            }
                        }
                    }

                    Section(selectedFolderID == nil ? "Marcadores Principales" : "En esta carpeta") {
                        if currentBookmarks.isEmpty {
                            Text("No hay marcadores guardados")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(theme.textTertiary(for: colorScheme))
                        } else {
                            ForEach(currentBookmarks) { item in
                                Button(action: {
                                    HapticManager.shared.touchLight()
                                    onSelectURL(item.url)
                                    dismiss()
                                }) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.title)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                                            .lineLimit(1)
                                        Text(item.displayHost)
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 2)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteBookmark(item)
                                    } label: {
                                        LiquidIconView(.trash, size: 16, color: .white)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Marcadores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingCreateFolder = true }) {
                        LiquidIconView(.newTab, size: 16)
                    }
                }
            }
            .alert("Nueva Carpeta", isPresented: $isShowingCreateFolder) {
                TextField("Nombre", text: $newFolderName)
                Button("Cancelar", role: .cancel) { newFolderName = "" }
                Button("Crear") {
                    createFolder()
                }
            }
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        if let storedB = StorageEngine.shared.load([BookmarkItem].self, from: "bookmarks.json") {
            self.bookmarks = storedB
        }
        if let storedF = StorageEngine.shared.load([BookmarkFolder].self, from: "bookmark_folders.json"), !storedF.isEmpty {
            self.folders = storedF
        }
    }

    private func createFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newF = BookmarkFolder(name: trimmed, orderIndex: folders.count)
        folders.append(newF)
        StorageEngine.shared.save(folders, to: "bookmark_folders.json")
        newFolderName = ""
    }

    private func deleteBookmark(_ item: BookmarkItem) {
        bookmarks.removeAll { $0.id == item.id }
        StorageEngine.shared.save(bookmarks, to: "bookmarks.json")
    }
}
