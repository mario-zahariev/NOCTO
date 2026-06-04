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
                    EmptyFavoritesSignalView()
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
                                        badge: VenueSignalResolver.badge(for: venue),
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

private struct EmptyFavoritesSignalView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(NoctoTheme.accent.opacity(0.14))
                    .frame(width: 76, height: 76)

                Text("✦")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(NoctoTheme.accent)
            }

            VStack(spacing: 8) {
                Text("Още нямаш избрани сигнали")
                    .font(.title3.weight(.black))
                    .foregroundStyle(NoctoTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Запази място със Spark, за да го държиш под ръка тази вечер.")
                    .font(.subheadline)
                    .foregroundStyle(NoctoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .noctoSurface(.raised, cornerRadius: 24)
        .padding(.horizontal, 18)
    }
}
