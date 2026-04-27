import SwiftUI

struct HomeView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    HeroParallaxCard(title: "NOCTO", subtitle: "Sofia nightlife intelligence")
                        .padding(.horizontal, 16)

                    ForEach(venues) { venue in
                        NavigationLink {
                            VenueDetailView(venue: venue)
                        } label: {
                            VenueCard(
                                venue: venue,
                                isFavorite: favorites.isFavorite(venue.id),
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
            .navigationTitle("Home")
        }
    }
}
