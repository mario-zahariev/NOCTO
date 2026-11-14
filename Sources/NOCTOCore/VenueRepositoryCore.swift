import Foundation

public enum VenueRepositoryCoreError: Error, Equatable {
    case invalidJSON
    case noValidVenues
}

public struct VenueRepositoryCore {
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
        // Duplicate identities are unsafe for SwiftUI ForEach and persisted favorites.
        guard Set(valid.map(\.id)).count == valid.count else { throw VenueRepositoryCoreError.invalidJSON }
        return valid
    }
}
