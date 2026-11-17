import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {
    @AppStorage("userName")          private var userName       = ""
    @AppStorage("userAge")           private var userAge        = 0
    @AppStorage("searchEngine")      private var searchEngine   = "Google"
    @AppStorage("accentColorHex")    private var accentColorHex = "#4A90E2"
    @AppStorage("autoCloseTabsDays") private var autoCloseDays  = 0
    @AppStorage("barPosition")       private var barPosition    = "Abajo"

    @Environment(\.dismiss) private var dismiss

    private let engines    = ["Google", "DuckDuckGo", "Brave", "Ecosia"]
    private let closeDays  = [0, 1, 7, 30]
    private let barPositions = ["Abajo", "Arriba"]
    private let accentColors = ["#4A90E2", "#FF3B30", "#34C759", "#FF9500", "#AF52DE", "#FF2D55"]

    var body: some View {
        NavigationView {
            Form {
                // Perfil
                Section("Perfil") {
                    HStack {
                        Text("Nombre")
                        Spacer()
                        TextField("Tu nombre", text: $userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Edad")
                        Spacer()
                        Stepper("\(userAge) años", value: $userAge, in: 10...99)
                    }
                }

                // Búsqueda
                Section("Motor de búsqueda") {
                    Picker("Motor", selection: $searchEngine) {
                        ForEach(engines, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                // Interfaz
                Section("Interfaz") {
                    Picker("Posición de la barra", selection: $barPosition) {
                        ForEach(barPositions, id: \.self) { Text($0).tag($0) }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Color de acento")
                            .font(.system(size: 15, design: .rounded))
                        HStack(spacing: 12) {
                            ForEach(accentColors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex) ?? .blue)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle().stroke(.white, lineWidth: accentColorHex == hex ? 3 : 0)
                                    )
                                    .shadow(color: (Color(hex: hex) ?? .blue).opacity(0.4), radius: 4)
                                    .onTapGesture { accentColorHex = hex }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Privacidad
                Section("Privacidad") {
                    Picker("Cerrar pestañas inactivas", selection: $autoCloseDays) {
                        Text("Nunca").tag(0)
                        Text("Tras 24h").tag(1)
                        Text("Tras 7 días").tag(7)
                        Text("Tras 30 días").tag(30)
                    }
                }

                // Info
                Section("Acerca de") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Fase 2)").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Motor")
                        Spacer()
                        Text("WebKit").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("IA integrada")
                        Spacer()
                        Text("Ninguna ✓").foregroundStyle(AppColors.secure)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Hecho") { dismiss() } }
            }
        }
    }
}
