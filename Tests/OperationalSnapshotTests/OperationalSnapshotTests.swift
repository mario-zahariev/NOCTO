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

    func testBestAfterTimeReturnsDashWhenWorkingHoursAreInvalid() {
        let venues: [Venue] = [
            Venue(
                id: UUID(),
                name: "Invalid A",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "N/A"
            ),
            Venue(
                id: UUID(),
                name: "Invalid B",
                type: .bar,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "xx:yy-04:00"
            )
        ]

        let snapshot = OperationalSnapshot(
            loadLatencyMs: 50,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )

        XCTAssertEqual(snapshot.bestAfterTime, "—")
    }

    func testBestAfterTimeUsesEarlierHourWhenModalCountsTie() {
        let venues: [Venue] = [
            Venue(
                id: UUID(),
                name: "Club A",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "22:00-03:00"
            ),
            Venue(
                id: UUID(),
                name: "Club B",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "22:30-04:00"
            ),
            Venue(
                id: UUID(),
                name: "Bar C",
                type: .bar,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "23:00-05:00"
            ),
            Venue(
                id: UUID(),
                name: "Bar D",
                type: .bar,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "23:30-04:00"
            )
        ]

        let snapshot = OperationalSnapshot(
            loadLatencyMs: 80,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )

        XCTAssertEqual(snapshot.bestAfterTime, "след 22:00")
    }

    func testLateNightCoverageHoursUsesMaxValidDurationOnly() {
        let venues: [Venue] = [
            Venue(
                id: UUID(),
                name: "Club A",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "23:00-03:00"
            ),
            Venue(
                id: UUID(),
                name: "Club B",
                type: .club,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "22:00-05:30"
            ),
            Venue(
                id: UUID(),
                name: "Bar C",
                type: .bar,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "20:00-00:30"
            ),
            Venue(
                id: UUID(),
                name: "Invalid",
                type: .other,
                latitude: 42.6977,
                longitude: 23.3219,
                workingHours: "n/a"
            )
        ]

        let snapshot = OperationalSnapshot(
            loadLatencyMs: 70,
            didLoadSucceed: true,
            lastErrorMessage: nil,
            venues: venues
        )

        XCTAssertEqual(snapshot.lateNightVenueCount, 2)
        XCTAssertEqual(snapshot.lateNightCoverageHours, 8)
    }

    func testVenueSignalResolverReturnsLateWaveForClubWithoutDuplicatingCloseTime() {
        let venue = Venue(
            id: UUID(),
            name: "Club X",
            type: .club,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "23:00-06:00"
        )

        XCTAssertEqual(VenueSignalResolver.badge(for: venue), .lateWave)
    }

    func testVenueSignalResolverReturnsQuietPickForEarlyClosingBar() {
        let venue = Venue(
            id: UUID(),
            name: "Bar Friday",
            type: .bar,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "18:00-02:00"
        )

        XCTAssertEqual(VenueSignalResolver.badge(for: venue), .quietPick)
    }

    func testVenueSignalResolverDoesNotReturnQuietPickAtExactlyThreeAM() {
        let venue = Venue(
            id: UUID(),
            name: "Bar Boundary",
            type: .bar,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "18:00-03:00"
        )

        XCTAssertEqual(VenueSignalResolver.badge(for: venue), .closesAt("03:00"))
    }

    func testVenueSignalResolverReturnsClosingBadgeForNonClubLateClose() {
        let venue = Venue(
            id: UUID(),
            name: "Terminal 1",
            type: .event,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "21:00-04:00"
        )

        XCTAssertEqual(VenueSignalResolver.badge(for: venue), .closesAt("04:00"))
    }

    func testVenueSignalResolverFallsBackToStartTimeForSameDayVenue() {
        let venue = Venue(
            id: UUID(),
            name: "Early Lounge",
            type: .lounge,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "17:00-23:00"
        )

        XCTAssertEqual(VenueSignalResolver.badge(for: venue), .startsAt("17:00"))
    }

    func testVenueSignalResolverReturnsNilForInvalidWorkingHours() {
        let venue = Venue(
            id: UUID(),
            name: "Invalid",
            type: .bar,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "n/a"
        )

        XCTAssertNil(VenueSignalResolver.badge(for: venue))
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
