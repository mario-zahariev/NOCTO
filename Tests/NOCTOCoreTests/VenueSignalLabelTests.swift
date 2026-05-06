import XCTest
@testable import NOCTOCore

final class VenueSignalLabelTests: XCTestCase {
    func testSignalLabelForClubUsesClosingTime() {
        let venue = Venue(
            id: UUID(),
            name: "Club X",
            type: .club,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "22:00-06:00"
        )

        XCTAssertEqual(venue.signalLabel, "Клуб · До 06:00")
        XCTAssertLessThanOrEqual(venue.signalLabel.count, 30)
    }

    func testSignalLabelFallbackIsNonEmpty() {
        let venue = Venue(
            id: UUID(),
            name: "Bar Y",
            type: .bar,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: ""
        )

        XCTAssertFalse(venue.signalLabel.isEmpty)
        XCTAssertLessThanOrEqual(venue.signalLabel.count, 30)
    }
}
