import XCTest
@testable import NOCTOAppLogic
import NOCTOCore

final class VenueRepositoryBoundaryTests: XCTestCase {
    func testLoadVenuesReturnsValidatedDomainModelsFromInjectedDataSource() async throws {
        let venue = makeVenue(name: "Boundary Club")
        let probe = DataSourceProbe(outcome: .success([venue]))
        let repository = VenueRepository(dataSource: ProbeVenueDataSource(probe: probe))

        let result = await repository.loadVenues()
        let loadCallCount = await probe.loadCallCount

        XCTAssertEqual(try result.get(), [venue])
        XCTAssertEqual(loadCallCount, 1)
    }

    func testVenueByIDReturnsNotFoundWhenDataSourceDoesNotContainID() async {
        let probe = DataSourceProbe(outcome: .success([makeVenue()]))
        let repository = VenueRepository(dataSource: ProbeVenueDataSource(probe: probe))

        let result = await repository.venue(id: UUID())
        let loadCallCount = await probe.loadCallCount

        XCTAssertEqual(result.failure, .notFound)
        XCTAssertEqual(loadCallCount, 1)
    }

    func testLoadVenuesMapsLocalRepositoryErrorsToVenueErrors() async {
        let cases: [(LocalVenueRepositoryError, VenueError)] = [
            (.missingResource, .notFound),
            (.invalidData, .validationFailed("venues.json is empty or malformed.")),
            (.decodingFailure, .validationFailed("Unable to decode venue data.")),
            (.noValidVenues, .validationFailed("No valid venues were found after validation."))
        ]

        for (sourceError, expectedError) in cases {
            let probe = DataSourceProbe(outcome: .localFailure(sourceError))
            let repository = VenueRepository(dataSource: ProbeVenueDataSource(probe: probe))

            let result = await repository.loadVenues()

            XCTAssertEqual(result.failure, expectedError)
        }
    }

    func testLoadVenuesRejectsEmptyDomainPayload() async {
        let probe = DataSourceProbe(outcome: .success([]))
        let repository = VenueRepository(dataSource: ProbeVenueDataSource(probe: probe))

        let result = await repository.loadVenues()

        XCTAssertEqual(result.failure, .validationFailed("No valid venues were loaded."))
    }

    private func makeVenue(name: String = "NOCTO Venue") -> Venue {
        Venue(
            id: UUID(),
            name: name,
            type: .club,
            latitude: 42.6977,
            longitude: 23.3219,
            workingHours: "23:00-05:00"
        )
    }
}

private struct ProbeVenueDataSource: VenueDataSource {
    let probe: DataSourceProbe

    func loadVenues() async throws -> [Venue] {
        try await probe.loadVenues()
    }
}

private actor DataSourceProbe {
    private(set) var loadCallCount = 0
    private let outcome: DataSourceOutcome

    init(outcome: DataSourceOutcome) {
        self.outcome = outcome
    }

    func loadVenues() throws -> [Venue] {
        loadCallCount += 1

        switch outcome {
        case .success(let venues):
            return venues
        case .localFailure(let error):
            throw error
        }
    }
}

private enum DataSourceOutcome: Sendable {
    case success([Venue])
    case localFailure(LocalVenueRepositoryError)
}

private extension Result where Failure == VenueError {
    var failure: VenueError? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}
