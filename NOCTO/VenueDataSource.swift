import Foundation
import NOCTOCore

typealias VenueDataSourceError = LocalVenueRepositoryError

protocol VenueDataSource {
    func loadVenues() throws -> [Venue]
}

struct LocalVenueDataSource: VenueDataSource {
    private let repository: LocalVenueRepository

    init(repository: LocalVenueRepository = .init()) {
        self.repository = repository
    }

    func loadVenues() throws -> [Venue] {
        try repository.loadVenues()
    }
}
