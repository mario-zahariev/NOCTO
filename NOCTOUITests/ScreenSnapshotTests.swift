import SwiftUI
import XCTest
@testable import NOCTO

@MainActor
final class ScreenSnapshotTests: SnapshotTestCase {
    func testHomeView_snapshot() async {
        let favorites = VisualFixtures.favoritesManager(favoriteIDs: [VisualFixtures.venueIDs[0]])
        let view = HomeView(venues: VisualFixtures.venues, favorites: favorites)
        await assertSnapshot(of: view, named: "home_view", viewport: .iPhone16Pro)
    }

    func testNightPulseView_snapshot() async {
        let view = NightPulseView(snapshot: VisualFixtures.snapshot())
        await assertSnapshot(of: view, named: "night_pulse_view", viewport: .iPhone16Pro)
    }

    func testProfileView_snapshot() async {
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
