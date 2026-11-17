import SwiftUI
import WebKit

// MARK: - FullPagePDFExporter

public struct FullPagePDFExporter {
    public static func exportPDF(from webView: WKWebView, completion: @escaping @Sendable (URL?) -> Void) {
        let pdfConfiguration = WKPDFConfiguration()

        webView.createPDF(configuration: pdfConfiguration) { result in
            switch result {
            case .success(let data):
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("LiquidBrowser_\(Int(Date().timeIntervalSince1970)).pdf")
                do {
                    try data.write(to: tempURL, options: .atomic)
                    DispatchQueue.main.async {
                        completion(tempURL)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
