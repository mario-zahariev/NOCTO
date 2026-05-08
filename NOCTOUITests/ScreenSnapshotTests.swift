import SwiftUI
import XCTest
@testable import NOCTO

@MainActor
final class ScreenSnapshotTests: SnapshotTestCase {
    func testHomeView_snapshot() async {
        guard let firstVenueID = VisualFixtures.venueIDs.first else {
            XCTFail("Visual fixture is missing venue IDs.")
            return
        }

        let favorites = VisualFixtures.favoritesManager(favoriteIDs: [firstVenueID])
        let view = HomeView(venues: VisualFixtures.venues, favorites: favorites)
        await assertSnapshot(of: view, named: "home_view", viewport: .iPhone16Pro)
    }

    func testNightPulseView_snapshot() async {
        let view = NightPulseView(snapshot: VisualFixtures.snapshot())
        await assertSnapshot(of: view, named: "night_pulse_view", viewport: .iPhone16Pro)
    }

    func testProfileView_snapshot() async {
        guard VisualFixtures.venueIDs.count >= 2 else {
            XCTFail("Visual fixture requires at least two venue IDs.")
            return
        }

        let favoriteIDs: Set<UUID> = [VisualFixtures.venueIDs[0], VisualFixtures.venueIDs[1]]
        let favorites = VisualFixtures.favoritesManager(
            favoriteIDs: favoriteIDs
        )
        let snapshot = VisualFixtures.snapshot()

        let view = ProfileView(
            favoritesCount: favoriteIDs.count,
            snapshot: snapshot,
            venues: VisualFixtures.venues,
            favorites: favorites
        )

        await assertSnapshot(of: view, named: "profile_view", viewport: .iPhone16Pro)
    }
}
