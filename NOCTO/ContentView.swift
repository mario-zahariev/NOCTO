import SwiftUI
import NOCTOCore

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var favorites = FavoritesManager()
    @State private var venues: [Venue] = []
    @State private var loadError: String?
    @State private var isLoading = true
    @State private var loadLatencyMs = 0
    @State private var lastLoadSucceeded = false
    @State private var selectedTab: NoctoInstrumentTab = .home

    var body: some View {
        ZStack {
            NoctoTheme.background.ignoresSafeArea()

            if isLoading {
                ProgressView("Зареждане...")
                    .tint(NoctoTheme.accent)
            } else if let loadError {
                ContentUnavailableView(
                    "Неуспешно зареждане",
                    systemImage: "exclamationmark.triangle",
                    description: Text(loadError)
                )
                .padding()
            } else {
                NoctoInstrumentTabShell(selection: $selectedTab) {
                    switch selectedTab {
                    case .home:
                        HomeView(venues: venues, favorites: favorites)
                    case .map:
                        AllVenuesMapView(venues: venues)
                    case .favorites:
                        FavoritesView(venues: venues, favorites: favorites)
                    case .pulse:
                        NightPulseView(snapshot: snapshot)
                    case .profile:
                        ProfileView(
                            favoritesCount: favorites.favoriteIDs.count,
                            snapshot: snapshot,
                            venues: venues,
                            favorites: favorites
                        )
                    }
                }
            }
        }
        .task {
            let startedAt = Date()
            isLoading = true
            loadError = nil
            do {
                venues = try await Task.detached(priority: .userInitiated) {
                    try VenueRepository().loadVenues()
                }.value
                lastLoadSucceeded = true
            } catch is CancellationError {
                isLoading = false
                return
            } catch {
                loadError = error.localizedDescription
                lastLoadSucceeded = false
            }
            loadLatencyMs = Int(Date().timeIntervalSince(startedAt) * 1000)
            isLoading = false

        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            guard newPhase == .active, !isLoading else { return }
            Task {
                if #available(iOS 16.1, *) {
                    await NoctoLiveActivityHandler.shared.sync(with: snapshot)
                }
            }
        }
        .onChange(of: isLoading, initial: false) { _, loading in
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
            lastErrorMessage: loadError,
            venues: venues
        )
    }
}
