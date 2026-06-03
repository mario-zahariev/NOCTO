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

    func testHourMinuteTupleParsesValidWorkingHours() {
        XCTAssertEqual(Venue.hourMinuteTuple(from: "22:30-05:15", at: 0)?.h, 22)
        XCTAssertEqual(Venue.hourMinuteTuple(from: "22:30-05:15", at: 0)?.m, 30)
        XCTAssertEqual(Venue.hourMinuteTuple(from: "22:30-05:15", at: 1)?.h, 5)
        XCTAssertEqual(Venue.hourMinuteTuple(from: "22:30-05:15", at: 1)?.m, 15)
    }

    func testHourMinuteTupleRejectsInvalidWorkingHours() {
        XCTAssertNil(Venue.hourMinuteTuple(from: "n/a", at: 0))
        XCTAssertNil(Venue.hourMinuteTuple(from: "22:99-05:00", at: 0))
        XCTAssertNil(Venue.hourMinuteTuple(from: "24:00-05:00", at: 0))
        XCTAssertNil(Venue.hourMinuteTuple(from: "22:00", at: 1))
    }
}
