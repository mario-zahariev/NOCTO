import Foundation

public enum VenueRepositoryCoreError: Error, Equatable, Sendable {
    case invalidJSON
    case noValidVenues
}

public struct VenueRepositoryCore: Sendable {
    public init() {}

    public func decode(from data: Data) throws -> [Venue] {
        let venues: [Venue]
        do {
            venues = try JSONDecoder().decode([Venue].self, from: data)
        } catch {
            throw VenueRepositoryCoreError.invalidJSON
        }

        let valid = venues.filter(\.isValid)
        guard !valid.isEmpty else { throw VenueRepositoryCoreError.noValidVenues }
        return valid
    }
}
