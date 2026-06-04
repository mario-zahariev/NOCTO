import NOCTOCore
import Foundation

typealias VenueRepositoryError = VenueError

protocol VenueRepositoryProviding: Sendable {
    func loadVenues() async -> Result<[Venue], VenueError>
    func venue(id: Venue.ID) async -> Result<Venue, VenueError>
}

struct VenueRepository: VenueRepositoryProviding {
    private let dataSource: any VenueDataSource

    init(dataSource: any VenueDataSource = LocalVenueDataSource()) {
        self.dataSource = dataSource
    }

    func loadVenues() async -> Result<[Venue], VenueError> {
        do {
            let venues = try await dataSource.loadVenues()
            guard !venues.isEmpty else {
                return .failure(.validationFailed("No valid venues were loaded."))
            }
            return .success(venues)
        } catch {
            return .failure(Self.map(error))
        }
    }

    func venue(id: Venue.ID) async -> Result<Venue, VenueError> {
        switch await loadVenues() {
        case .success(let venues):
            guard let venue = venues.first(where: { $0.id == id }) else {
                return .failure(.notFound)
            }
            return .success(venue)
        case .failure(let error):
            return .failure(error)
        }
    }

    func requireVenues() async throws -> [Venue] {
        try await loadVenues().get()
    }

    private static func map(_ error: Error) -> VenueError {
        if let error = error as? VenueError {
            return error
        }

        if let error = error as? LocalVenueRepositoryError {
            switch error {
            case .missingResource:
                return .notFound
            case .invalidData:
                return .validationFailed("venues.json is empty or malformed.")
            case .decodingFailure:
                return .validationFailed("Unable to decode venue data.")
            case .noValidVenues:
                return .validationFailed("No valid venues were found after validation.")
            }
        }

        return .underlying(error.localizedDescription)
    }
}
