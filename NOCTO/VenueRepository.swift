import NOCTOCore
import Foundation

typealias VenueRepositoryError = VenueDataSourceError

struct VenueRepository {
    private let dataSource: any VenueDataSource

    init(dataSource: any VenueDataSource = LocalVenueDataSource()) {
        self.dataSource = dataSource
    }

    func loadVenues() throws -> [Venue] {
        try dataSource.loadVenues()
    }
}
