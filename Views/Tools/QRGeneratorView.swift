import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - QRGeneratorView (Monochrome Liquid Glass)

public struct QRGeneratorView: View {
    public let urlString: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    public init(urlString: String) {
        self.urlString = urlString
    }

    public var body: some View {
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    if let qrImage = generateQRCode(from: urlString) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                            }
                            .shadow(
                                color: theme.shadowColor(for: colorScheme),
                                radius: 16,
                                y: 6
                            )
                    }

                    VStack(spacing: 6) {
                        Text("Escanea para abrir enlace")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))

                        Text(urlString)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Código QR")
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
            }
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
