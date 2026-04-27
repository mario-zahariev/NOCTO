import SwiftUI
import NOCTOCore

struct FavoritesView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    private var favoriteVenues: [Venue] {
        venues.filter { favorites.isFavorite($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteVenues.isEmpty {
                    ContentUnavailableView(
                        "Няма запазени места",
                        systemImage: "heart.slash",
                        description: Text("Маркирай любими клубове и барове от Home.")
                    )
                } else {
                    List(favoriteVenues) { venue in
                        NavigationLink(venue.name) {
                            VenueDetailView(venue: venue)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Favorites")
        }
    }
}
