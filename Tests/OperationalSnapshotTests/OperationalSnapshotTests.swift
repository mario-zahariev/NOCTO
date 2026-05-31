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

        XCTAssertEqual(snapshot.bestAfterTime, "след 23:00")
    }

    func testConfidenceScoreIsHardWhenValidationIsFull() {
        let venues = makeVenues(
            count: 10,
            type: .club,
            workingHours: "23:00-05:00",
            includeOptionalFields: true
        )

        let snapshot = OperationalSnapshot(
            loadLatencyMs: 42,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )

        XCTAssertEqual(snapshot.confidenceSource, .hardData)
        XCTAssertEqual(snapshot.confidenceScore, 100)
        XCTAssertEqual(snapshot.signalConfidenceLabel, "Пълна")
        XCTAssertEqual(snapshot.confidenceValidationLabel, "Валидация: Пълна (100%)")
    }

    func testConfidenceScoreFallsInMixedBand() {
        let venues = makeVenues(
            count: 6,
            type: .bar,
            workingHours: "22:00-03:00",
            includeOptionalFields: true
        )

        let snapshot = OperationalSnapshot(
            loadLatencyMs: 120,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )

        XCTAssertEqual(snapshot.confidenceSource, .mixedData)
        XCTAssertEqual(snapshot.confidenceScore, 85)
    }

    func testConfidenceScoreStaysBelowSixtyForSoftData() {
        let snapshot = OperationalSnapshot(
            loadLatencyMs: 420,
            didLoadSucceed: false,
            lastErrorMessage: "decode-failed",
            venues: []
        )

        XCTAssertEqual(snapshot.confidenceSource, .softData)
        XCTAssertTrue(snapshot.confidenceScore < 60)
        XCTAssertEqual(snapshot.signalConfidenceLabel, "Ниска")
    }

    private func makeVenues(
        count: Int,
        type: Venue.VenueType,
        workingHours: String,
        includeOptionalFields: Bool
    ) -> [Venue] {
        (0..<count).map { index in
            Venue(
                id: UUID(),
                name: "Venue \(index)",
                imageName: includeOptionalFields ? "image" : "",
                type: type,
                description: includeOptionalFields ? "Описание" : "",
                latitude: 42.6977 + Double(index) * 0.001,
                longitude: 23.3219 + Double(index) * 0.001,
                address: includeOptionalFields ? "Адрес \(index)" : "",
                workingHours: workingHours
            )
        }
    }
}
