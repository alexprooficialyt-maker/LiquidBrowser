import Foundation

// MARK: - Download

struct Download: Identifiable {
    let id: UUID
    var url: URL
    var filename: String
    var totalBytes: Int64
    var receivedBytes: Int64
    var state: DownloadState
    var localURL: URL?
    var startedAt: Date

    init(id: UUID = UUID(), url: URL, filename: String) {
        self.id            = id
        self.url           = url
        self.filename      = filename
        self.totalBytes    = 0
        self.receivedBytes = 0
        self.state         = .pending
        self.startedAt     = Date()
    }

    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(receivedBytes) / Double(totalBytes)
    }

    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle   = .file
        return formatter.string(fromByteCount: totalBytes)
    }

    enum DownloadState: Equatable {
        case pending
        case downloading
        case paused
        case completed
        case failed(String)
    }
}
