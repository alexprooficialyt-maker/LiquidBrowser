import Foundation

// MARK: - DownloadManager

@Observable
final class DownloadManager: NSObject {

    var downloads: [Download] = []

    private var urlSession: URLSession!
    private var tasks: [UUID: URLSessionDownloadTask] = [:]

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: - Iniciar descarga

    func start(url: URL, filename: String? = nil) {
        let name = filename ?? url.lastPathComponent
        var dl   = Download(url: url, filename: name.isEmpty ? "archivo" : name)
        dl.state = .downloading
        downloads.insert(dl, at: 0)

        let task = urlSession.downloadTask(with: url)
        tasks[dl.id] = task
        task.resume()
    }

    // MARK: - Control

    func pause(id: UUID) {
        tasks[id]?.cancel(byProducingResumeData: { _ in })
        update(id: id, state: .paused)
    }

    func remove(id: UUID) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
        downloads.removeAll { $0.id == id }
    }

    // MARK: - Helpers

    private func update(id: UUID, state: Download.DownloadState? = nil,
                        received: Int64? = nil, total: Int64? = nil, localURL: URL? = nil) {
        DispatchQueue.main.async {
            guard let idx = self.downloads.firstIndex(where: { $0.id == id }) else { return }
            if let v = state    { self.downloads[idx].state         = v }
            if let v = received { self.downloads[idx].receivedBytes = v }
            if let v = total    { self.downloads[idx].totalBytes    = v }
            if let v = localURL { self.downloads[idx].localURL      = v }
        }
    }

    private func downloadID(for task: URLSessionTask) -> UUID? {
        tasks.first(where: { $0.value == task })?.key
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadManager: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let id = downloadID(for: downloadTask) else { return }
        update(id: id, received: totalBytesWritten, total: totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let id = downloadID(for: downloadTask) else { return }
        let dest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = downloads.first(where: { $0.id == id })?.filename ?? "archivo"
        let destURL  = dest.appendingPathComponent(filename)
        try? FileManager.default.moveItem(at: location, to: destURL)
        update(id: id, state: .completed, localURL: destURL)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        guard let error, let id = downloadID(for: task) else { return }
        update(id: id, state: .failed(error.localizedDescription))
    }
}
