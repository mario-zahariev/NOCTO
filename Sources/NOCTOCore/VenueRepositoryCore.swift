import Foundation

public enum VenueRepositoryCoreError: Error {
    case invalidJSON
    case noValidVenues
}

public struct VenueRepositoryCore {
    public init() {}

    public func decode(from data: Data) throws -> [VenueCore] {
        let venues: [VenueCore]
        do {
            venues = try JSONDecoder().decode([VenueCore].self, from: data)
        } catch {
            throw VenueRepositoryCoreError.invalidJSON
        }

        let valid = venues.filter(\.isValid)
        guard !valid.isEmpty else { throw VenueRepositoryCoreError.noValidVenues }
        return valid
    }
}
