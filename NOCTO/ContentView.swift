import SwiftUI
import NOCTOCore

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var favorites = FavoritesManager()
    @StateObject private var catalogViewModel = VenueCatalogViewModel()
    @State private var loadLatencyMs = 0
    @State private var lastLoadSucceeded = false
    @State private var selectedTab: NoctoTab = .home

    var body: some View {
        ZStack {
            NoctoTheme.background.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                VenueCatalogView(
                    viewModel: catalogViewModel,
                    favorites: favorites,
                    onInitialLoad: loadCatalogIfNeeded,
                    onRefresh: loadCatalog
                )
                .tag(NoctoTab.home)

                AllVenuesMapView(venues: catalogViewModel.venues)
                    .tag(NoctoTab.map)

                FavoritesView(venues: catalogViewModel.venues, favorites: favorites)
                    .tag(NoctoTab.favorites)

                NightPulseView(snapshot: snapshot)
                    .tag(NoctoTab.pulse)

                ProfileView(
                    favoritesCount: favorites.favoriteIDs.count,
                    snapshot: snapshot,
                    venues: catalogViewModel.venues,
                    favorites: favorites
                )
                .tag(NoctoTab.profile)
            }
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom) {
                NoctoInstrumentTabBar(selection: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            guard
                newPhase == .active,
                !catalogViewModel.isLoading,
                catalogViewModel.loadState != .idle
            else { return }

            Task {
                if #available(iOS 16.1, *) {
                    await NoctoLiveActivityHandler.shared.sync(with: snapshot)
                }
            }
        }
        .onChange(of: catalogViewModel.isLoading, initial: false) { _, loading in
            guard loading == false, scenePhase == .active else { return }
            Task {
                if #available(iOS 16.1, *) {
                    await NoctoLiveActivityHandler.shared.sync(with: snapshot)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var snapshot: OperationalSnapshot {
        OperationalSnapshot(
            loadLatencyMs: loadLatencyMs,
            didLoadSucceed: lastLoadSucceeded,
            lastErrorMessage: catalogViewModel.errorMessage,
            venues: catalogViewModel.venues
        )
    }

    private func loadCatalogIfNeeded() async {
        guard catalogViewModel.loadState == .idle else { return }
        await loadCatalog()
    }

    private func loadCatalog() async {
        let startedAt = Date()

        await catalogViewModel.fetchCatalog()

        loadLatencyMs = Int(Date().timeIntervalSince(startedAt) * 1000)
        lastLoadSucceeded = catalogViewModel.errorMessage == nil
    }
}

private enum NoctoTab: CaseIterable, Hashable {
    case home
    case map
    case favorites
    case pulse
    case profile

    var label: String {
        switch self {
        case .home: return "Начало"
        case .map: return "Карта"
        case .favorites: return "Любими"
        case .pulse: return "Пулс"
        case .profile: return "Профил"
        }
    }
}

private struct NoctoInstrumentTabBar: View {
    @Binding var selection: NoctoTab

    var body: some View {
        HStack(spacing: 2) {
            ForEach(NoctoTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                    Haptics.tap()
                } label: {
                    NoctoInstrumentTabItem(tab: tab, isSelected: selection == tab)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
            }
        }
        .padding(5)
        .noctoSurface(.floatingBar, cornerRadius: 32)
    }
}

private struct NoctoInstrumentTabItem: View {
    let tab: NoctoTab
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            NoctoInstrumentGlyph(tab: tab, isSelected: isSelected)
                .frame(width: 28, height: 28)

            Text(tab.label)
                .font(.caption2.weight(.black))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(isSelected ? NoctoTheme.accent : NoctoTheme.textSecondary.opacity(0.64))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background {
            if isSelected {
                ZStack {
                    RadialGradient(
                        colors: [
                            NoctoTheme.accent.opacity(0.24),
                            NoctoTheme.ultraviolet.opacity(0.075),
                            .clear
                        ],
                        center: .top,
                        startRadius: 4,
                        endRadius: 42
                    )
                    .frame(width: 62, height: 58)
                    .offset(y: -13)
                    .allowsHitTesting(false)

                    LinearGradient(
                        colors: [
                            .clear,
                            NoctoTheme.accent.opacity(0.20),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 42, height: 1.6)
                    .offset(y: -22)
                    .blur(radius: 1.2)
                    .allowsHitTesting(false)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

private struct NoctoInstrumentGlyph: View {
    let tab: NoctoTab
    let isSelected: Bool

    private var tint: Color {
        isSelected ? NoctoTheme.accent : NoctoTheme.textSecondary.opacity(0.64)
    }

    var body: some View {
        ZStack {
            switch tab {
            case .home:
                Circle()
                    .trim(from: 0.08, to: 0.84)
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                    .rotationEffect(.degrees(-38))

                Circle()
                    .stroke(tint.opacity(0.38), lineWidth: 1.4)
                    .frame(width: 15, height: 15)

                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)

            case .map:
                Circle()
                    .stroke(tint.opacity(0.42), style: StrokeStyle(lineWidth: 1.6, dash: [3, 3]))
                    .frame(width: 25, height: 25)

                Rectangle()
                    .fill(tint)
                    .frame(width: 2, height: 28)

                Rectangle()
                    .fill(tint)
                    .frame(width: 28, height: 2)

                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)

            case .favorites:
                NoctoSparkGlyph()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.2, lineJoin: .round))
                    .frame(width: 25, height: 25)

            case .pulse:
                HStack(alignment: .center, spacing: 3) {
                    ForEach([10.0, 18.0, 24.0, 14.0], id: \.self) { height in
                        Capsule()
                            .fill(tint)
                            .frame(width: 3.4, height: height)
                    }
                }

            case .profile:
                VStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(tint)
                                    .frame(width: 3.8, height: 3.8)
                            }
                        }
                    }
                }
                .padding(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(tint.opacity(0.7), lineWidth: 1.4)
                )
            }
        }
    }
}

private struct NoctoSparkGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = [
            CGPoint(x: center.x, y: rect.minY),
            CGPoint(x: center.x + rect.width * 0.16, y: center.y - rect.height * 0.16),
            CGPoint(x: rect.maxX, y: center.y),
            CGPoint(x: center.x + rect.width * 0.16, y: center.y + rect.height * 0.16),
            CGPoint(x: center.x, y: rect.maxY),
            CGPoint(x: center.x - rect.width * 0.16, y: center.y + rect.height * 0.16),
            CGPoint(x: rect.minX, y: center.y),
            CGPoint(x: center.x - rect.width * 0.16, y: center.y - rect.height * 0.16)
        ]

        var path = Path()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}
