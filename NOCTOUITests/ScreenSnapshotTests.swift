import SwiftUI
import XCTest
@testable import NOCTO

@MainActor
final class ScreenSnapshotTests: SnapshotTestCase {
    func testHomeView_snapshot() {
        let favorites = VisualFixtures.favoritesManager(favoriteIDs: [VisualFixtures.venueIDs[0]])
        let view = HomeView(venues: VisualFixtures.venues, favorites: favorites)
        assertSnapshot(of: view, named: "home_view", viewport: .iPhone16Pro)
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
