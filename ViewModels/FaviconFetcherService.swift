import SwiftUI
import UIKit

// MARK: - FaviconFetcherService (Multi-Tier Caching & Resolution Engine)

@MainActor
public final class FaviconFetcherService {
    public static let shared = FaviconFetcherService()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        memoryCache.countLimit = 250
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB

        let baseDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let faviconsDir = baseDir.appendingPathComponent("SmartBotFavicons", isDirectory: true)
        if !fileManager.fileExists(atPath: faviconsDir.path) {
            try? fileManager.createDirectory(at: faviconsDir, withIntermediateDirectories: true)
        }
        self.cacheDirectory = faviconsDir
    }

    // MARK: - Public Fetching

    public func fetchFavicon(for url: URL?) async -> UIImage? {
        guard let url = url, let host = url.host, !host.isEmpty else { return nil }
        let cleanHost = host.replacingOccurrences(of: "www.", with: "").lowercased()
        let cacheKey = NSString(string: cleanHost)

        // 1. Memoria RAM
        if let cached = memoryCache.object(forKey: cacheKey) {
            return cached
        }

        // 2. Caché en Disco
        let fileURL = cacheDirectory.appendingPathComponent("\(cleanHost).png")
        if let diskData = try? Data(contentsOf: fileURL), let diskImage = UIImage(data: diskData) {
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }

        // 3. Descarga de Google S2 Favicon API (Resolución HD 128x128)
        let s2URLString = "https://www.google.com/s2/favicons?domain=\(cleanHost)&sz=128"
        if let s2URL = URL(string: s2URLString),
           let (data, response) = try? await URLSession.shared.data(from: s2URL),
           let http = response as? HTTPURLResponse, http.statusCode == 200,
           let image = UIImage(data: data) {
            storeImage(image, key: cacheKey, fileURL: fileURL)
            return image
        }

        // 4. Intento con apple-touch-icon.png en la raíz
        let scheme = url.scheme ?? "https"
        if let appleTouchURL = URL(string: "\(scheme)://\(cleanHost)/apple-touch-icon.png"),
           let (data, response) = try? await URLSession.shared.data(from: appleTouchURL),
           let http = response as? HTTPURLResponse, http.statusCode == 200,
           let image = UIImage(data: data) {
            storeImage(image, key: cacheKey, fileURL: fileURL)
            return image
        }

        // 5. Intento con favicon.ico nativo
        if let icoURL = URL(string: "\(scheme)://\(cleanHost)/favicon.ico"),
           let (data, response) = try? await URLSession.shared.data(from: icoURL),
           let http = response as? HTTPURLResponse, http.statusCode == 200,
           let image = UIImage(data: data) {
            storeImage(image, key: cacheKey, fileURL: fileURL)
            return image
        }

        return nil
    }

    private func storeImage(_ image: UIImage, key: NSString, fileURL: URL) {
        memoryCache.setObject(image, forKey: key)
        if let pngData = image.pngData() {
            try? pngData.write(to: fileURL, options: .atomic)
        }
    }

    public func clearFaviconCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - FaviconView (SwiftUI Liquid Glass Squircle View)

public struct FaviconView: View {
    public let url: URL?
    public var title: String?
    public var size: CGFloat
    public var cornerRadius: CGFloat
    public var showBorder: Bool

    @Environment(\.colorScheme) private var systemColorScheme
    @State private var loadedImage: UIImage? = nil
    @State private var isLoading: Bool = false

    public init(
        url: URL?,
        title: String? = nil,
        size: CGFloat = 32,
        cornerRadius: CGFloat = 8,
        showBorder: Bool = true
    ) {
        self.url = url
        self.title = title
        self.size = size
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        ZStack {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                fallbackMonogramView(theme: theme, scheme: scheme)
            }
        }
        .frame(width: size, height: size)
        .overlay {
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
            }
        }
        .task(id: url) {
            await loadFavicon()
        }
    }

    @ViewBuilder
    private func fallbackMonogramView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        let letter = monogramLetter()
        let gradientFill = LinearGradient(
            colors: [
                theme.surfaceElevated(for: scheme),
                theme.surfaceElevated(for: scheme).opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(gradientFill)

            if !letter.isEmpty {
                Text(letter)
                    .font(.system(size: size * 0.44, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))
            } else {
                LiquidIconView(.globeLanguage, size: size * 0.48, color: theme.textSecondary(for: scheme))
            }
        }
    }

    private func monogramLetter() -> String {
        if let title = title, let first = title.trimmingCharacters(in: .whitespacesAndNewlines).first {
            return String(first).uppercased()
        }
        if let host = url?.host?.replacingOccurrences(of: "www.", with: ""),
           let first = host.first {
            return String(first).uppercased()
        }
        return ""
    }

    private func loadFavicon() async {
        guard let url = url else { return }
        isLoading = true
        let image = await FaviconFetcherService.shared.fetchFavicon(for: url)
        withAnimation(.easeOut(duration: 0.2)) {
            self.loadedImage = image
            self.isLoading = false
        }
    }
}
