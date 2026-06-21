import NOCTOCore
import Foundation

typealias VenueRepositoryError = VenueDataSourceError

struct VenueRepository {
    private let dataSource: any VenueDataSource

    init(dataSource: any VenueDataSource = LocalVenueDataSource()) {
        self.dataSource = dataSource
    }

    func loadVenues() async throws -> [Venue] {
        try await dataSource.loadVenues()
    }
}
