import Foundation
import XCTest
@testable import NOCTO

@MainActor
enum VisualFixtures {
    static let venueIDs: [UUID] = [
        fixtureUUID("00000000-0000-0000-0000-000000000001"),
        fixtureUUID("00000000-0000-0000-0000-000000000002"),
        fixtureUUID("00000000-0000-0000-0000-000000000003")
    ]

    static let venues: [Venue] = [
        Venue(
            id: venueIDs[0],
            name: "EXE Club",
            imageName: "",
            type: .club,
            description: "Техно пулс",
            latitude: 42.6977,
            longitude: 23.3219,
            address: "ул. Раковски 113, София",
            workingHours: "23:00-06:00"
        ),
        Venue(
            id: venueIDs[1],
            name: "Bedroom Premium",
            imageName: "",
            type: .club,
            description: "Късна вълна",
            latitude: 42.6901,
            longitude: 23.3320,
            address: "бул. Витоша 12, София",
            workingHours: "22:00-06:00"
        ),
        Venue(
            id: venueIDs[2],
            name: "Bar Friday",
            imageName: "",
            type: .bar,
            description: "Коктейли",
            latitude: 42.6954,
            longitude: 23.3250,
            address: "ул. Шишман 24, София",
            workingHours: "20:00-02:00"
        )
    ]

    static func snapshot() -> OperationalSnapshot {
        OperationalSnapshot(
            loadLatencyMs: 42,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )
    }

    static func favoritesManager(favoriteIDs: Set<UUID>) -> FavoritesManager {
        let suiteName = "NOCTOUITests.Favorites"
        let key = "com.nocto.favoriteVenueIDs"
        let defaults: UserDefaults

        if let scopedDefaults = UserDefaults(suiteName: suiteName) {
            scopedDefaults.removePersistentDomain(forName: suiteName)
            defaults = scopedDefaults
        } else {
            XCTFail("Cannot create dedicated test defaults suite '\(suiteName)'. Falling back to standard defaults.")
            UserDefaults.standard.removeObject(forKey: key)
            defaults = .standard
        }

        defaults.set(favoriteIDs.map(\.uuidString).sorted(), forKey: key)
        return FavoritesManager(defaults: defaults)
    }

    @available(iOS 16.1, *)
    static func liveActivityState(score: Int) -> NoctoAttributes.ContentState {
        let clampedScore = max(0, min(score, 100))
        let integrityState: NoctoIntegrityState = clampedScore < 60 ? .offlineLowConfidence : .live

        return NoctoAttributes.ContentState(
            confidenceScore: clampedScore,
            confidenceLabel: confidenceLabel(for: clampedScore),
            sourceLabel: sourceLabel(for: clampedScore),
            activeVenueCount: 12,
            lateNightVenueCount: 8,
            integrityState: integrityState,
            updatedAt: Date(timeIntervalSince1970: 1_715_000_000)
        )
    }

    private static func confidenceLabel(for score: Int) -> String {
        switch score {
        case 90...:
            return "Пълна"
        case 70...:
            return "Стабилна"
        case 60...:
            return "Ограничена"
        default:
            return "Ниска"
        }
    }

    private static func sourceLabel(for score: Int) -> String {
        if score >= 90 {
            return "Твърд източник"
        }
        if score >= 70 {
            return "Смесен източник"
        }
        return "Мек източник"
    }

    private static func fixtureUUID(_ raw: String) -> UUID {
        if let uuid = UUID(uuidString: raw) {
            return uuid
        }
        XCTFail("Invalid fixture UUID: \(raw)")
        return UUID()
    }
}
