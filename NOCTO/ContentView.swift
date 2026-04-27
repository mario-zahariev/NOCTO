import SwiftUI
import NOCTOCore

struct ContentView: View {
    @StateObject private var favorites = FavoritesManager()
    @State private var venues: [Venue] = []
    @State private var loadError: String?
    @State private var isLoading = false

    private let repository = VenueRepository()

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
                TabView {
                    HomeView(venues: venues, favorites: favorites)
                        .tabItem { Label("Начало", systemImage: "house") }

                    AllVenuesMapView(venues: venues)
                        .tabItem { Label("Карта", systemImage: "map") }

                    FavoritesView(venues: venues, favorites: favorites)
                        .tabItem { Label("Любими", systemImage: "heart") }

                    NightPulseView(venuesCount: venues.count)
                        .tabItem { Label("Пулс", systemImage: "waveform.path.ecg") }

                    AdminDashboardView(venues: venues, favorites: favorites)
                        .tabItem { Label("Админ", systemImage: "gauge.with.dots.needle.67percent") }
                }
                .tint(NoctoTheme.accent)
            }
        }
        .task {
            isLoading = true
            loadError = nil
            do {
                venues = try await repository.loadVenues()
            } catch {
                loadError = error.localizedDescription
            }
            isLoading = false
        }
    }
}
