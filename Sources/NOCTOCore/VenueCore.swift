import Foundation

public struct VenueCore: Codable, Equatable {
    public enum VenueType: String, Codable {
        case club
        case bar
        case lounge
        case event
        case other
    }

    public let id: UUID
    public let name: String
    public let type: VenueType
    public let latitude: Double
    public let longitude: Double

    public init(id: UUID, name: String, type: VenueType, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
    }

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (-90.0...90.0).contains(latitude) &&
            (-180.0...180.0).contains(longitude)
    }
}
