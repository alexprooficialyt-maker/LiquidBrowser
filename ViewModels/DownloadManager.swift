import Foundation
import Observation

// MARK: - DownloadManager

@Observable
public final class DownloadManager: NSObject, @unchecked Sendable, URLSessionDownloadDelegate {
    public static let shared = DownloadManager()

    public var downloads: [DownloadItem] = []
    private var session: URLSession!
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private var resumeDataMap: [UUID: Data] = [:]

    private override init() {
        super.init()
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        loadDownloads()
    }

    private func loadDownloads() {
        if let stored: [DownloadItem] = StorageEngine.shared.loadJSON(from: "downloads.json") {
            self.downloads = stored
        }
    }

    public func saveDownloads() {
        StorageEngine.shared.saveJSON(downloads, to: "downloads.json")
    }

    // MARK: - Download Controls

    public func startDownload(url: URL, suggestedFileName: String? = nil) {
        let fileName = suggestedFileName ?? url.lastPathComponent
        let resolvedName = fileName.isEmpty ? "archivo" : fileName

        let item = DownloadItem(
            originalURL: url,
            suggestedFileName: resolvedName,
            state: .queued
        )

        downloads.insert(item, at: 0)
        saveDownloads()

        let task = session.downloadTask(with: url)
        downloadTasks[item.id] = task
        task.resume()

        updateItem(id: item.id, state: .downloading(progress: 0.0))
    }

    public func pauseDownload(id: UUID) {
        guard let task = downloadTasks[id] else { return }
        task.cancel { [weak self] data in
            guard let self = self, let data = data else { return }
            self.resumeDataMap[id] = data
            self.updateItem(id: id, state: .paused(resumeDataLength: data.count))
        }
        downloadTasks.removeValue(forKey: id)
    }

    public func resumeDownload(id: UUID) {
        if let data = resumeDataMap[id] {
            let task = session.downloadTask(withResumeData: data)
            downloadTasks[id] = task
            task.resume()
            resumeDataMap.removeValue(forKey: id)
            updateItem(id: id, state: .downloading(progress: 0.0))
        } else if let item = downloads.first(where: { $0.id == id }) {
            startDownload(url: item.originalURL, suggestedFileName: item.suggestedFileName)
        }
    }

    public func cancelDownload(id: UUID) {
        downloadTasks[id]?.cancel()
        downloadTasks.removeValue(forKey: id)
        resumeDataMap.removeValue(forKey: id)
        downloads.removeAll { $0.id == id }
        saveDownloads()
    }

    private func updateItem(id: UUID, state: DownloadState) {
        DispatchQueue.main.async {
            if let idx = self.downloads.firstIndex(where: { $0.id == id }) {
                self.downloads[idx].state = state
                self.saveDownloads()
            }
        }
    }

    // MARK: - URLSessionDownloadDelegate

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let itemID = downloadTasks.first(where: { $0.value == downloadTask })?.key else { return }
        let progress = totalBytesExpectedToWrite > 0 ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : 0.0

        DispatchQueue.main.async {
            if let idx = self.downloads.firstIndex(where: { $0.id == itemID }) {
                self.downloads[idx].receivedBytes = totalBytesWritten
                self.downloads[idx].totalBytes = totalBytesExpectedToWrite
                self.downloads[idx].state = .downloading(progress: progress)
            }
        }
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let itemID = downloadTasks.first(where: { $0.value == downloadTask })?.key else { return }

        DispatchQueue.main.async {
            guard let idx = self.downloads.firstIndex(where: { $0.id == itemID }) else { return }
            let suggestedName = self.downloads[idx].suggestedFileName
            let destinationURL = StorageEngine.shared.downloadDestinationURL(suggestedFileName: suggestedName)

            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: location, to: destinationURL)
                self.downloads[idx].state = .completed(relativeFilePath: destinationURL.lastPathComponent)
                self.downloads[idx].completedAt = Date()
                HapticManager.shared.notifySuccess()
            } catch {
                self.downloads[idx].state = .failed(reason: error.localizedDescription)
            }

            self.saveDownloads()
            self.downloadTasks.removeValue(forKey: itemID)
        }
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error as? NSError, error.code != NSURLErrorCancelled {
            guard let itemID = downloadTasks.first(where: { $0.value == task })?.key else { return }
            DispatchQueue.main.async {
                if let idx = self.downloads.firstIndex(where: { $0.id == itemID }) {
                    self.downloads[idx].state = .failed(reason: error.localizedDescription)
                    self.saveDownloads()
                }
                self.downloadTasks.removeValue(forKey: itemID)
            }
        }
    }
}
