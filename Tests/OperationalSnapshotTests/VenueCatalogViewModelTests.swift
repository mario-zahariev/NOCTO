import XCTest
@testable import NOCTOAppLogic
import NOCTOCore

final class VenueCatalogViewModelTests: XCTestCase {
    @MainActor
    func testFetchCatalogPublishesSuccessfulCatalogState() async {
        let venue = makeVenue(name: "Catalog Club")
        let probe = VenueRepositoryProbe(outcomes: [.success([venue])])
        let viewModel = VenueCatalogViewModel(repository: ProbeVenueRepository(probe: probe))

        await viewModel.fetchCatalog()

        XCTAssertEqual(viewModel.venues, [venue])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.loadState, .loaded(count: 1))
        let loadCallCount = await probe.loadCount()
        XCTAssertEqual(loadCallCount, 1)
    }

    @MainActor
    func testFetchCatalogPublishesSafeFailureStateWithoutLeakingUnderlyingDetails() async {
        let probe = VenueRepositoryProbe(outcomes: [.failure(.underlying("Bearer nocto-prod-token"))])
        let viewModel = VenueCatalogViewModel(repository: ProbeVenueRepository(probe: probe))

        await viewModel.fetchCatalog()

        let expectedMessage = "Възникна проблем при зареждането на заведенията."
        XCTAssertEqual(viewModel.venues, [])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, expectedMessage)
        XCTAssertEqual(viewModel.loadState, .failed(message: expectedMessage))
    }

    @MainActor
    func testRefreshKeepsLastGoodCatalogWhenFollowUpLoadFails() async {
        let venue = makeVenue(name: "Stable Catalog")
        let probe = VenueRepositoryProbe(outcomes: [
            .success([venue]),
            .failure(.offline)
        ])
        let viewModel = VenueCatalogViewModel(repository: ProbeVenueRepository(probe: probe))

        await viewModel.fetchCatalog()
        await viewModel.refresh()

        let expectedMessage = "Няма достъп до данните за заведенията в офлайн режим."
        XCTAssertEqual(viewModel.venues, [venue])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, expectedMessage)
        XCTAssertEqual(viewModel.loadState, .failed(message: expectedMessage))
        let loadCallCount = await probe.loadCount()
        XCTAssertEqual(loadCallCount, 2)
    }

    @MainActor
    func testInitialVenuesStartInLoadedState() {
        let venue = makeVenue()
        let probe = VenueRepositoryProbe(outcomes: [.failure(.notFound)])
        let viewModel = VenueCatalogViewModel(
            repository: ProbeVenueRepository(probe: probe),
            venues: [venue]
        )

        XCTAssertEqual(viewModel.venues, [venue])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.loadState, .loaded(count: 1))
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

private struct ProbeVenueRepository: VenueRepositoryProviding {
    let probe: VenueRepositoryProbe

    func loadVenues() async -> Result<[Venue], VenueError> {
        await probe.loadVenues()
    }

    func venue(id: Venue.ID) async -> Result<Venue, VenueError> {
        await probe.venue(id: id)
    }
}

private actor VenueRepositoryProbe {
    private(set) var loadCallCount = 0
    private var outcomes: [Result<[Venue], VenueError>]

    init(outcomes: [Result<[Venue], VenueError>]) {
        self.outcomes = outcomes
    }

    func loadVenues() -> Result<[Venue], VenueError> {
        loadCallCount += 1
        guard !outcomes.isEmpty else { return .failure(.notFound) }
        return outcomes.removeFirst()
    }

    func venue(id: Venue.ID) -> Result<Venue, VenueError> {
        switch loadVenues() {
        case .success(let venues):
            guard let venue = venues.first(where: { $0.id == id }) else {
                return .failure(.notFound)
            }
            return .success(venue)
        case .failure(let error):
            return .failure(error)
        }
    }

    func loadCount() -> Int {
        loadCallCount
    }
}
