import SwiftUI
import NOCTOCore

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var favorites = FavoritesManager()
    @StateObject private var catalogViewModel = VenueCatalogViewModel()
    @State private var loadLatencyMs = 0
    @State private var lastLoadSucceeded = false
    @State private var selectedTab: NoctoTab = .home
    @State private var hidesRootChrome = false

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / NoctoHTML.baseWidth

            ZStack(alignment: .bottom) {
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

                    ProfileView(
                        favoritesCount: favorites.favoriteIDs.count,
                        snapshot: snapshot,
                        venues: catalogViewModel.venues,
                        favorites: favorites
                    )
                    .tag(NoctoTab.profile)
                }
                .toolbar(.hidden, for: .tabBar)

                if !hidesRootChrome {
                    NoctoInstrumentTabBar(selection: $selectedTab, scale: scale)
                        .padding(.horizontal, 12 * scale)
                        .padding(.bottom, 14 * scale)
                        .zIndex(20)
                }
            }
            .ignoresSafeArea()
        }
        .onPreferenceChange(NoctoChromeHiddenPreferenceKey.self) { hidesRootChrome = $0 }
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
        .statusBarHidden(true)
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
    case profile

    var label: String {
        switch self {
        case .home: return "Пулс"
        case .map: return "Карта"
        case .favorites: return "Запазени"
        case .profile: return "Профил"
        }
    }
}

private struct NoctoInstrumentTabBar: View {
    @Binding var selection: NoctoTab
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            ForEach(NoctoTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                    Haptics.tap()
                } label: {
                    NoctoInstrumentTabItem(tab: tab, isSelected: selection == tab, scale: scale)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
            }
        }
        .frame(height: 52 * scale)
        .padding(.horizontal, 6 * scale)
        .noctoElevatedSurface(cornerRadius: NoctoTheme.Radius.tabBar * scale)
    }
}

private struct NoctoInstrumentTabItem: View {
    let tab: NoctoTab
    let isSelected: Bool
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 3 * scale) {
            NoctoInstrumentGlyph(tab: tab, isSelected: isSelected)
                .frame(width: 18 * scale, height: 18 * scale)
                .opacity(isSelected ? 1 : 0.28)

            Text(tab.label)
                .font(.system(size: 6 * scale, weight: .bold))
                .tracking(1.5 * scale)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isSelected ? NoctoTheme.accent : NoctoTheme.textTertiary)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10 * scale)
        .padding(.vertical, 4 * scale)
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
                BookmarkGlyph()
                    .stroke(tint, style: StrokeStyle(lineWidth: isSelected ? 1.8 : 1.5, lineJoin: .round))
                    .background {
                        if isSelected {
                            BookmarkGlyph()
                                .fill(tint.opacity(0.10))
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
        .noctoSignalGlow(isSelected ? .active : .none)
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

private struct BookmarkGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.79, y: rect.height * 0.88))
        path.addLine(to: CGPoint(x: rect.width * 0.50, y: rect.height * 0.71))
        path.addLine(to: CGPoint(x: rect.width * 0.21, y: rect.height * 0.88))
        path.addLine(to: CGPoint(x: rect.width * 0.21, y: rect.height * 0.21))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.29, y: rect.height * 0.13),
            control1: CGPoint(x: rect.width * 0.21, y: rect.height * 0.17),
            control2: CGPoint(x: rect.width * 0.25, y: rect.height * 0.13)
        )
        path.addLine(to: CGPoint(x: rect.width * 0.71, y: rect.height * 0.13))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.79, y: rect.height * 0.21),
            control1: CGPoint(x: rect.width * 0.75, y: rect.height * 0.13),
            control2: CGPoint(x: rect.width * 0.79, y: rect.height * 0.17)
        )
        path.closeSubpath()
        return path
    }
}
