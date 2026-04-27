import NOCTOCore

typealias VenueRepositoryError = LocalVenueRepositoryError

struct VenueRepository {
    private let core = LocalVenueRepository()

    func loadVenues() throws -> [Venue] {
        try core.loadVenues()
    }
}
