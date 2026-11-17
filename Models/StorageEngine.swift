import Foundation
import UIKit

// MARK: - StorageEngine

public final class StorageEngine: @unchecked Sendable {
    public static let shared = StorageEngine()

    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.liquidbrowser.storage", qos: .utility)

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var appSupportDirectory: URL {
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LiquidBrowser", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private var snapshotsDirectory: URL {
        let url = appSupportDirectory.appendingPathComponent("Snapshots", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    public var downloadsDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Descargas", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private init() {}

    // MARK: - Generic Persistence

    public func save<T: Encodable>(_ object: T, to fileName: String) {
        queue.async {
            let fileURL = self.appSupportDirectory.appendingPathComponent(fileName)
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(object)
                try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            } catch {
                NSLog("StorageEngine write error for \(fileName): \(error.localizedDescription)")
            }
        }
    }

    public func saveJSON<T: Encodable>(_ object: T, to fileName: String) {
        save(object, to: fileName)
    }

    public func load<T: Decodable>(_ type: T.Type, from fileName: String) -> T? {
        let fileURL = appSupportDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            NSLog("StorageEngine read error for \(fileName): \(error.localizedDescription)")
            return nil
        }
    }

    public func loadJSON<T: Decodable>(from fileName: String) -> T? {
        return load(T.self, from: fileName)
    }

    public func delete(fileName: String) {
        queue.async {
            let fileURL = self.appSupportDirectory.appendingPathComponent(fileName)
            if self.fileManager.fileExists(atPath: fileURL.path) {
                try? self.fileManager.removeItem(at: fileURL)
            }
        }
    }

    // MARK: - Snapshot Disk Management

    public func saveSnapshot(image: UIImage, for tabID: UUID) -> String {
        let fileName = "tab_\(tabID.uuidString).jpg"
        let fileURL = snapshotsDirectory.appendingPathComponent(fileName)
        queue.async {
            if let data = image.jpegData(compressionQuality: 0.72) {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
        return fileName
    }

    public func loadSnapshot(fileName: String) -> UIImage? {
        let fileURL = snapshotsDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    public func deleteSnapshot(fileName: String) {
        queue.async {
            let fileURL = self.snapshotsDirectory.appendingPathComponent(fileName)
            if self.fileManager.fileExists(atPath: fileURL.path) {
                try? self.fileManager.removeItem(at: fileURL)
            }
        }
    }

    public func cleanAllSnapshots() {
        queue.async {
            if let files = try? self.fileManager.contentsOfDirectory(at: self.snapshotsDirectory, includingPropertiesForKeys: nil) {
                for file in files {
                    try? self.fileManager.removeItem(at: file)
                }
            }
        }
    }

    // MARK: - Downloads Target Calculation

    public func downloadDestinationURL(suggestedFileName: String) -> URL {
        var destination = downloadsDirectory.appendingPathComponent(suggestedFileName)
        var counter = 1
        let name = (suggestedFileName as NSString).deletingPathExtension
        let ext = (suggestedFileName as NSString).pathExtension

        while fileManager.fileExists(atPath: destination.path) {
            let newName = ext.isEmpty ? "\(name)_\(counter)" : "\(name)_\(counter).\(ext)"
            destination = downloadsDirectory.appendingPathComponent(newName)
            counter += 1
        }
        return destination
    }

    // MARK: - Pinned Tabs Logic (Poner Primero / Mover a Index 0)

    public func pinTabToTop(tabID: UUID, in tabs: inout [TabModel]) {
        guard let idx = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        var tab = tabs.remove(at: idx)
        tab.isPinned = true
        tabs.insert(tab, at: 0)
        save(tabs, to: "tabs.json")
    }

    public func unpinTab(tabID: UUID, in tabs: inout [TabModel]) {
        guard let idx = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[idx].isPinned = false
        save(tabs, to: "tabs.json")
    }

    // MARK: - Clear All User Data

    public func clearAllUserData() {
        cleanAllSnapshots()
        delete(fileName: "tabs.json")
        delete(fileName: "spaces.json")
        delete(fileName: "history.json")
        delete(fileName: "search_history.json")
        delete(fileName: "bookmarks.json")
        delete(fileName: "bookmark_folders.json")
        delete(fileName: "downloads.json")
        delete(fileName: "reading_list.json")
    }
}
