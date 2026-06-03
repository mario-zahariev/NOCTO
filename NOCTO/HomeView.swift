import SwiftUI
import NOCTOCore

struct HomeView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    HeroParallaxCard(title: "NOCTO", subtitle: "Интелигентен гид за нощна София")
                        .equatable()
                        .padding(.horizontal, 16)

                    ForEach(venues) { venue in
                        NavigationLink {
                            VenueDetailView(venue: venue)
                        } label: {
                            VenueCard(
                                venue: venue,
                                isFavorite: favorites.isFavorite(venue.id),
                                badge: VenueSignalResolver.badge(for: venue),
                                onToggleFavorite: {
                                    favorites.toggle(venue.id)
                                    Haptics.tap()
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 10)
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Начало")
        }
    }
}
