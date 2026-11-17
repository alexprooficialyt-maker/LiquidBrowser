import SwiftUI

// MARK: - ReaderView

struct ReaderView: View {
    @Bindable var viewModel: BrowserViewModel
    @State private var content   = "Extrayendo contenido…"
    @State private var fontSize: CGFloat = 17
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.system(size: fontSize, design: .serif))
                    .foregroundStyle(.primary)
                    .lineSpacing(6)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
            }
            .navigationTitle(viewModel.tabManager.activeTab?.displayTitle ?? "Lectura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button(action: { if fontSize > 12 { fontSize -= 2 } }) {
                            Text("A").font(.system(size: 14, weight: .medium))
                        }
                        Button(action: { if fontSize < 26 { fontSize += 2 } }) {
                            Text("A").font(.system(size: 20, weight: .bold))
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.extractReaderContent { text in
                content = text.isEmpty ? "No se pudo extraer el contenido de esta página." : text
            }
        }
    }
}
