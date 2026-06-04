import SwiftUI
import XCTest
import NOCTOCore
@testable import NOCTO

@MainActor
final class ScreenSnapshotTests: SnapshotTestCase {
    func testHomeView_snapshot() {
        let favorites = VisualFixtures.favoritesManager(favoriteIDs: [VisualFixtures.venueIDs[0]])
        let view = HomeView(venues: VisualFixtures.venues, favorites: favorites)
        assertSnapshot(of: view, named: "home_view", viewport: .iPhone16Pro)
    }

    func testVenueCatalogView_snapshot() {
        let favorites = VisualFixtures.favoritesManager(favoriteIDs: [VisualFixtures.venueIDs[0]])
        let viewModel = VenueCatalogViewModel(
            repository: SnapshotVenueRepository(venues: VisualFixtures.venues),
            venues: VisualFixtures.venues
        )
        let view = VenueCatalogView(
            viewModel: viewModel,
            favorites: favorites,
            onInitialLoad: {},
            onRefresh: {}
        )

        assertSnapshot(of: view, named: "venue_catalog_view", viewport: .iPhone16Pro)
    }

    func testNightPulseView_snapshot() {
        let view = NightPulseView(snapshot: VisualFixtures.snapshot())
        assertSnapshot(of: view, named: "night_pulse_view", viewport: .iPhone16Pro)
    }

    func testProfileView_snapshot() {
        let favorites = VisualFixtures.favoritesManager(
            favoriteIDs: [VisualFixtures.venueIDs[0], VisualFixtures.venueIDs[1]]
        )
        let snapshot = VisualFixtures.snapshot()

        let view = ProfileView(
            favoritesCount: 2,
            snapshot: snapshot,
            venues: VisualFixtures.venues,
            favorites: favorites
        )

        assertSnapshot(of: view, named: "profile_view", viewport: .iPhone16Pro)
    }
}

private struct SnapshotVenueRepository: VenueRepositoryProviding {
    let venues: [Venue]

    func loadVenues() async -> Result<[Venue], VenueError> {
        .success(venues)
    }

    func venue(id: Venue.ID) async -> Result<Venue, VenueError> {
        guard let venue = venues.first(where: { $0.id == id }) else {
            return .failure(.notFound)
        }
        return .success(venue)
    }
}
