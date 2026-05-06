import XCTest
@testable import NOCTOAppLogic
import NOCTOCore

final class OperationalSnapshotTests: XCTestCase {
    func testBestAfterTimeReturnsModalOpeningHour() {
        let venues: [Venue] = [
            Venue(
                id: UUID(),
                name: "Club A",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "23:30-05:00"
            ),
            Venue(
                id: UUID(),
                name: "Club B",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "23:00-04:00"
            ),
            Venue(
                id: UUID(),
                name: "Bar C",
                type: .bar,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "22:00-03:00"
            )
        ]

        let snapshot = OperationalSnapshot(
            loadLatencyMs: 64,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )

        XCTAssertEqual(snapshot.bestAfterTime, "After 23:00")
    }
}
