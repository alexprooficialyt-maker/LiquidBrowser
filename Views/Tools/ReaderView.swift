import SwiftUI

// MARK: - ReaderView (Monochrome Liquid Glass)

public struct ReaderView: View {
    public let article: ReaderArticle
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var fontSize: CGFloat = 18
    @State private var isSerif: Bool = true

    public init(article: ReaderArticle) {
        self.article = article
    }

    public var body: some View {
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Title & Meta
                        VStack(alignment: .leading, spacing: 8) {
                            Text(article.title)
                                .font(isSerif ? .system(size: fontSize + 6, weight: .bold, design: .serif) : .system(size: fontSize + 6, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                                .lineSpacing(4)

                            HStack(spacing: 8) {
                                if let byline = article.byline, !byline.isEmpty {
                                    Text(byline)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))

                                    Text("•")
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                                }

                                if let site = article.siteName, !site.isEmpty {
                                    Text(site)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))

                                    Text("•")
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                                }

                                Text("\(article.readingTimeMinutes) min de lectura")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(theme.textSecondary(for: colorScheme))
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                        Divider()
                            .overlay(theme.specularBorder(for: colorScheme))

                        // Body Content
                        Text(article.textContent)
                            .font(isSerif ? .system(size: fontSize, design: .serif) : .system(size: fontSize, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                            .lineSpacing(fontSize * 0.4)
                            .textSelection(.enabled)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Modo Lectura")
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
                    HStack(spacing: 16) {
                        Button(action: {
                            HapticManager.shared.touchLight()
                            isSerif.toggle()
                        }) {
                            Text(isSerif ? "Sans" : "Serif")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(theme.cardBackground(for: colorScheme))
                                .clipShape(Capsule())
                        }

                        Button(action: {
                            if fontSize > 14 {
                                HapticManager.shared.touchLight()
                                fontSize -= 2
                            }
                        }) {
                            Text("A-")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                        }

                        Button(action: {
                            if fontSize < 26 {
                                HapticManager.shared.touchLight()
                                fontSize += 2
                            }
                        }) {
                            Text("A+")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                        }
                    }
                }
            }
        }
    }
}
