import Foundation

// MARK: - BookmarkManager

@Observable
final class BookmarkManager {

    private let bookmarksKey = "bookmarks_v1"
    private let foldersKey   = "folders_v1"

    var bookmarks: [Bookmark]       = []
    var folders:   [BookmarkFolder] = []

    init() { load() }

    // MARK: - CRUD Marcadores

    func add(title: String, url: URL, folderID: UUID? = nil) {
        let bm = Bookmark(title: title, url: url, folderID: folderID)
        bookmarks.insert(bm, at: 0)
        save()
    }

    func remove(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        save()
    }

    func isBookmarked(url: URL) -> Bool {
        bookmarks.contains { $0.url == url }
    }

    func toggle(title: String, url: URL) {
        if let existing = bookmarks.first(where: { $0.url == url }) {
            remove(id: existing.id)
        } else {
            add(title: title, url: url)
        }
    }

    // MARK: - CRUD Carpetas

    func createFolder(name: String) -> UUID {
        let folder = BookmarkFolder(name: name)
        folders.append(folder)
        save()
        return folder.id
    }

    func removeFolder(id: UUID) {
        folders.removeAll { $0.id == id }
        bookmarks.removeAll { $0.folderID == id }
        save()
    }

    func bookmarks(inFolder id: UUID?) -> [Bookmark] {
        bookmarks.filter { $0.folderID == id }
    }

    // MARK: - Persistencia

    private func save() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        }
        if let data = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(data, forKey: foldersKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) {
            bookmarks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: foldersKey),
           let decoded = try? JSONDecoder().decode([BookmarkFolder].self, from: data) {
            folders = decoded
        }
    }
}
