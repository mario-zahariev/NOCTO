import Foundation
import NOCTOCore

typealias VenueDataSourceError = LocalVenueRepositoryError

protocol VenueDataSource: Sendable {
    func loadVenues() async throws -> [Venue]
}

struct LocalVenueDataSource: VenueDataSource {
    private let repository: LocalVenueRepository

    init(repository: LocalVenueRepository = .init()) {
        self.repository = repository
    }

    func loadVenues() async throws -> [Venue] {
        try repository.loadVenues()
    }
}
