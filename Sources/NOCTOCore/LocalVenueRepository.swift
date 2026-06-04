import Foundation

public enum LocalVenueRepositoryError: LocalizedError, Equatable, Sendable {
    case missingResource
    case invalidData
    case decodingFailure
    case noValidVenues

    public var errorDescription: String? {
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

public protocol VenueRepositoryProtocol: Sendable {
    func loadVenues() throws -> [Venue]
}

public struct LocalVenueRepository: VenueRepositoryProtocol, @unchecked Sendable {
    private let bundle: Bundle
    private let resourceName: String
    private let resourceExtension: String
    private let decoder = VenueRepositoryCore()

    public init(
        bundle: Bundle = .main,
        resourceName: String = "venues",
        resourceExtension: String = "json"
    ) {
        self.bundle = bundle
        self.resourceName = resourceName
        self.resourceExtension = resourceExtension
    }

    public func loadVenues() throws -> [Venue] {
        guard let url = bundle.url(forResource: resourceName, withExtension: resourceExtension) else {
            throw LocalVenueRepositoryError.missingResource
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LocalVenueRepositoryError.invalidData
        }
        guard !data.isEmpty else { throw LocalVenueRepositoryError.invalidData }

        do {
            return try decoder.decode(from: data)
        } catch let error as VenueRepositoryCoreError {
            switch error {
            case .invalidJSON:
                throw LocalVenueRepositoryError.decodingFailure
            case .noValidVenues:
                throw LocalVenueRepositoryError.noValidVenues
            }
        } catch {
            throw LocalVenueRepositoryError.decodingFailure
        }
    }
}
