import SwiftUI
import NOCTOCore

struct ContentView: View {
    @StateObject private var favorites = FavoritesManager()
    @State private var venues: [Venue] = []
    @State private var loadError: String?

    private let repository = VenueRepository()

    var body: some View {
        ZStack {
            NoctoTheme.background.ignoresSafeArea()

            if let loadError {
                ContentUnavailableView(
                    "Неуспешно зареждане",
                    systemImage: "exclamationmark.triangle",
                    description: Text(loadError)
                )
                .padding()
            } else {
                TabView {
                    HomeView(venues: venues, favorites: favorites)
                        .tabItem { Label("Home", systemImage: "house") }

                    AllVenuesMapView(venues: venues)
                        .tabItem { Label("Map", systemImage: "map") }

                    FavoritesView(venues: venues, favorites: favorites)
                        .tabItem { Label("Favorites", systemImage: "heart") }

                    NightPulseView(venuesCount: venues.count)
                        .tabItem { Label("Pulse", systemImage: "waveform.path.ecg") }

                    AdminDashboardView(venues: venues, favorites: favorites)
                        .tabItem { Label("Admin", systemImage: "gauge.with.dots.needle.67percent") }
                }
                .tint(NoctoTheme.accent)
            }
        }
        .task {
            do {
                venues = try repository.loadVenues()
            } catch {
                loadError = error.localizedDescription
            }
        }
    }
}
