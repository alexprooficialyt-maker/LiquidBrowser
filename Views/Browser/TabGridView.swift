import SwiftUI

// MARK: - TabGridView

struct TabGridView: View {
    @Bindable var viewModel: BrowserViewModel
    var onDismiss: () -> Void

    @State private var searchQuery  = ""
    @State private var showNewSpace = false
    @State private var newSpaceName = ""
    @State private var newSpaceEmoji = "🗂️"
    @Environment(\.colorScheme) private var colorScheme

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    private var displayedTabs: [BrowserTab] {
        viewModel.tabManager.searchTabs(query: searchQuery)
            .filter { $0.isPrivate == viewModel.isPrivateMode }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                (colorScheme == .dark
                    ? Color(red: 0.07, green: 0.07, blue: 0.12)
                    : Color(red: 0.94, green: 0.94, blue: 0.98))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Selector de espacios
                    spacePicker

                    // Buscador de pestañas
                    tabSearchBar

                    // Grid
                    ScrollView {
                        // Pestañas fijadas
                        if !viewModel.tabManager.pinnedTabs.isEmpty && searchQuery.isEmpty {
                            pinnedSection
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(displayedTabs) { tab in
                                TabCard(tab: tab, isActive: tab.id == viewModel.tabManager.activeTabID) {
                                    viewModel.selectTab(tab.id)
                                    onDismiss()
                                } onClose: {
                                    viewModel.tabManager.close(tabID: tab.id)
                                } onPin: {
                                    viewModel.tabManager.pin(tabID: tab.id)
                                }
                            }
                        }
                        .padding(16)
                    }

                    // Bottom bar
                    bottomBar
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showNewSpace) { newSpaceSheet }
    }

    // MARK: - Espacios

    @ViewBuilder
    private var spacePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.tabManager.spaces) { space in
                    Button(action: { viewModel.tabManager.activeSpaceID = space.id }) {
                        HStack(spacing: 6) {
                            Text(space.emoji).font(.system(size: 14))
                            Text(space.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(viewModel.tabManager.activeSpaceID == space.id ? .white : .primary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(
                            viewModel.tabManager.activeSpaceID == space.id
                                ? AnyView(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                : AnyView(Color.primary.opacity(0.08))
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Button(action: { showNewSpace = true }) {
                    HStack(spacing: 4) {
                        PlusIcon()
                            .stroke(.blue, style: .init(lineWidth: 1.8, lineCap: .round))
                            .frame(width: 12, height: 12)
                        Text("Nuevo espacio")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.blue)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
    }

    // MARK: - Buscador pestañas

    @ViewBuilder
    private var tabSearchBar: some View {
        HStack(spacing: 10) {
            HistoryIcon()
                .stroke(.secondary, style: .init(lineWidth: 1.6, lineCap: .round))
                .frame(width: 16, height: 16)
            TextField("Buscar pestaña…", text: $searchQuery)
                .font(.system(size: 15, design: .rounded))
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.primary.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
    }

    // MARK: - Sección fijadas

    @ViewBuilder
    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FIJADAS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.tabManager.pinnedTabs) { tab in
                        PinnedTabChip(tab: tab, isActive: tab.id == viewModel.tabManager.activeTabID) {
                            viewModel.selectTab(tab.id); onDismiss()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        HStack {
            // Modo privado toggle
            Button(action: { viewModel.isPrivateMode.toggle() }) {
                HStack(spacing: 6) {
                    BrowserIconView(icon: .private, size: 18,
                                    color: viewModel.isPrivateMode ? AppColors.privateMode : .secondary)
                    Text(viewModel.isPrivateMode ? "Privado" : "Normal")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(viewModel.isPrivateMode ? AppColors.privateMode : .secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Restaurar última pestaña cerrada
            if !viewModel.tabManager.recentlyClosed.isEmpty {
                Button(action: {
                    viewModel.tabManager.restoreLastClosed()
                    onDismiss()
                }) {
                    Text("Restaurar")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Nueva pestaña
            Button(action: {
                _ = viewModel.tabManager.newTab(isPrivate: viewModel.isPrivateMode)
                onDismiss()
            }) {
                PlusIcon()
                    .stroke(.blue, style: .init(lineWidth: 2.2, lineCap: .round))
                    .frame(width: 22, height: 22)
                    .padding(10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(.ultraThinMaterial)
    }

    // MARK: - Hoja nuevo espacio

    @ViewBuilder
    private var newSpaceSheet: some View {
        NavigationView {
            Form {
                Section("Nombre del espacio") {
                    HStack {
                        TextField("Emoji", text: $newSpaceEmoji)
                            .frame(width: 40)
                        TextField("Nombre", text: $newSpaceName)
                    }
                }
            }
            .navigationTitle("Nuevo Espacio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showNewSpace = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        if !newSpaceName.isEmpty {
                            _ = viewModel.tabManager.createSpace(name: newSpaceName, emoji: newSpaceEmoji)
                        }
                        showNewSpace = false
                    }
                    .disabled(newSpaceName.isEmpty)
                }
            }
        }
    }
}

// MARK: - TabCard

struct TabCard: View {
    let tab: BrowserTab
    var isActive: Bool
    var onSelect: () -> Void
    var onClose:  () -> Void
    var onPin:    () -> Void

    @State private var showContextMenu = false

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Previsualización
                ZStack {
                    if let snapshot = tab.snapshot {
                        Image(uiImage: snapshot)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.primary.opacity(0.05))
                            .frame(height: 120)
                            .overlay(
                                GlobeIconSmall()
                                    .stroke(Color.secondary.opacity(0.3),
                                            style: .init(lineWidth: 1.5, lineCap: .round))
                                    .frame(width: 32, height: 32)
                            )
                    }
                }
                .frame(maxWidth: .infinity)

                // Info
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tab.displayTitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(tab.displayHost)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(action: onClose) {
                        Circle()
                            .fill(Color.primary.opacity(0.12))
                            .frame(width: 20, height: 20)
                            .overlay(
                                PlusIcon()
                                    .stroke(.secondary, style: .init(lineWidth: 1.4, lineCap: .round))
                                    .frame(width: 8, height: 8)
                                    .rotationEffect(.degrees(45))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
        .buttonStyle(.plain)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(isActive ? Color.blue : Color.primary.opacity(0.1), lineWidth: isActive ? 2 : 0.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .contextMenu {
            Button(action: onPin) {
                Label(tab.isPinned ? "Desfijar" : "Fijar", systemImage: tab.isPinned ? "pin.slash" : "pin")
            }
            Button(role: .destructive, action: onClose) {
                Label("Cerrar pestaña", systemImage: "xmark")
            }
        }
    }
}

// MARK: - PinnedTabChip

struct PinnedTabChip: View {
    let tab: BrowserTab
    var isActive: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                GlobeIconSmall()
                    .stroke(isActive ? Color.blue : Color.secondary,
                            style: .init(lineWidth: 1.5, lineCap: .round))
                    .frame(width: 14, height: 14)
                Text(tab.displayHost.isEmpty ? tab.displayTitle : tab.displayHost)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(isActive ? .blue : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(isActive ? Color.blue.opacity(0.12) : Color.primary.opacity(0.07))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(isActive ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// Icono globo pequeño para tarjetas
private struct GlobeIconSmall: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let r  = min(rect.width, rect.height) * 0.46
        p.addEllipse(in: .init(x: cx-r, y: cy-r, width: r*2, height: r*2))
        p.move(to: .init(x: cx - r, y: cy)); p.addLine(to: .init(x: cx + r, y: cy))
        p.move(to: .init(x: cx, y: cy - r)); p.addLine(to: .init(x: cx, y: cy + r))
        return p
    }
}
