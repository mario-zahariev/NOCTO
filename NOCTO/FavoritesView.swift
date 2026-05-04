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
                        description: Text("Запазвай места от Начало или Карта и ги дръж тук за вечерта.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(favoriteVenues) { venue in
                                NavigationLink {
                                    VenueDetailView(venue: venue)
                                } label: {
                                    VenueCard(
                                        venue: venue,
                                        isFavorite: true,
                                        onToggleFavorite: {
                                            withAnimation {
                                                favorites.toggle(venue.id)
                                            }
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
                }
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Любими")
        }
    }
}
