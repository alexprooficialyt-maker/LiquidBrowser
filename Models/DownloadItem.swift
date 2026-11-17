import Foundation

public enum DownloadState: Codable, Equatable, Sendable {
    case queued
    case downloading(progress: Double)
    case paused(resumeDataLength: Int)
    case completed(relativeFilePath: String)
    case failed(reason: String)

    public var isTerminal: Bool {
        switch self {
        case .completed, .failed: return true
        default: return false
        }
    }
}

public struct DownloadItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var originalURL: URL
    public var suggestedFileName: String
    public var totalBytes: Int64
    public var receivedBytes: Int64
    public var state: DownloadState
    public var startedAt: Date
    public var completedAt: Date?
    public var mimeType: String?

    public init(
        id: UUID = UUID(),
        originalURL: URL,
        suggestedFileName: String,
        totalBytes: Int64 = 0,
        receivedBytes: Int64 = 0,
        state: DownloadState = .queued,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        mimeType: String? = nil
    ) {
        self.id = id
        self.originalURL = originalURL
        self.suggestedFileName = suggestedFileName
        self.totalBytes = totalBytes
        self.receivedBytes = receivedBytes
        self.state = state
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.mimeType = mimeType
    }

    public var progressRatio: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(receivedBytes) / Double(totalBytes)
    }

    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalBytes > 0 ? totalBytes : receivedBytes)
    }

    public var progressPercentageString: String {
        "\(Int(progressRatio * 100))%"
    }
}
