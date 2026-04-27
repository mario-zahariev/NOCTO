import Foundation

enum VenueRepositoryError: LocalizedError {
    case missingResource
    case invalidData
    case decodingFailure
    case noValidVenues

    var errorDescription: String? {
        switch self {
        case .missingResource:
            return "venues.json was not found in the app bundle."
        case .invalidData:
            return "venues.json is empty or malformed."
        case .decodingFailure:
            return "Unable to decode venue data."
        case .noValidVenues:
            return "No valid venues were found after validation."
        }
    }
}

struct VenueRepository {
    func loadVenues() throws -> [Venue] {
        guard let url = Bundle.main.url(forResource: "venues", withExtension: "json") else {
            throw VenueRepositoryError.missingResource
        }

        let data = try Data(contentsOf: url)
        guard !data.isEmpty else { throw VenueRepositoryError.invalidData }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        let venues: [Venue]
        do {
            venues = try decoder.decode([Venue].self, from: data)
        } catch {
            throw VenueRepositoryError.decodingFailure
        }

        let validVenues = venues.filter(\.isValid)
        guard !validVenues.isEmpty else { throw VenueRepositoryError.noValidVenues }
        return validVenues
    }
}
