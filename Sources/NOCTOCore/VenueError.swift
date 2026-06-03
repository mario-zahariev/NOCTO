import Foundation

public enum VenueError: LocalizedError, Equatable, Sendable {
    case notFound
    case validationFailed(String)
    case underlying(String)
    case offline

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Venue was not found."
        case .validationFailed(let reason):
            return "Venue validation failed: \(reason)"
        case .underlying(let message):
            return message
        case .offline:
            return "Venue data is unavailable while offline."
        }
    }
}
