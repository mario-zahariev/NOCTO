import XCTest
import CoreLocation
@testable import NOCTOAppLogic
import NOCTOCore

final class ProximityRankerTests: XCTestCase {
    private let location = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)

    func testRanksCloserVenueFirst() {
        let near = venue(name: "Near")
        let far = venue(name: "Far", latitude: 42.7077)
        let ranked = ProximityRanker.rank(venues: [far, near], from: location)
        XCTAssertEqual(ranked.map(\.venue.name), ["Near", "Far"])
    }

    func testDistanceLabelsCoverMetersAndKilometers() {
        let place = venue()
        XCTAssertEqual(ProximityRankedVenue(venue: place, distanceMeters: 0, score: 0).distanceLabel, "0 m")
        XCTAssertEqual(ProximityRankedVenue(venue: place, distanceMeters: 650, score: 0).distanceLabel, "650 m")
        XCTAssertEqual(ProximityRankedVenue(venue: place, distanceMeters: 1500, score: 0).distanceLabel, "1.5 km")
    }

    func testOpenVenueReceivesExactlyTenPointBonus() throws {
        let place = venue(hours: "10:00-20:00")
        let openScore = try score(place, at: "2026-01-15T12:00:00+02:00")
        let closedScore = try score(place, at: "2026-01-15T21:00:00+02:00")
        XCTAssertEqual(openScore, 94, accuracy: 0.001)
        XCTAssertEqual(openScore - closedScore, 10, accuracy: 0.001)
    }

    func testOvernightHoursIncludeOpeningAndExcludeClosing() throws {
        let place = venue(hours: "22:00-04:00")
        for timestamp in ["2026-01-15T22:00:00+02:00", "2026-01-16T01:00:00+02:00", "2026-01-16T03:59:00+02:00"] {
            XCTAssertEqual(try score(place, at: timestamp), 94, accuracy: 0.001)
        }
        for timestamp in ["2026-01-15T21:59:00+02:00", "2026-01-16T04:00:00+02:00", "2026-01-16T12:00:00+02:00"] {
            XCTAssertEqual(try score(place, at: timestamp), 84, accuracy: 0.001)
        }
    }

    func testHoursUseSofiaTimezoneIncludingSummerOffset() throws {
        let place = venue(hours: "22:00-04:00")
        XCTAssertEqual(try score(place, at: "2026-01-15T20:00:00Z"), 94, accuracy: 0.001)
        XCTAssertEqual(try score(place, at: "2026-07-15T19:00:00Z"), 94, accuracy: 0.001)
    }

    func testInvalidHoursDoNotEarnAvailabilityBonus() throws {
        XCTAssertEqual(try score(venue(hours: "invalid"), at: "2026-01-15T12:00:00Z"), 84, accuracy: 0.001)
    }

    private func score(_ venue: Venue, at timestamp: String) throws -> Double {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: timestamp))
        return try XCTUnwrap(ProximityRanker.rank(venues: [venue], from: location, now: date).first).score
    }

    private func venue(name: String = "Test", latitude: Double = 42.6977, hours: String = "") -> Venue {
        Venue(id: UUID(), name: name, type: .bar, latitude: latitude, longitude: 23.3219, workingHours: hours)
    }
}
