import Foundation
import CoreLocation

public struct VenueCore: Codable, Equatable, Identifiable {
    public enum VenueType: String, Codable, CaseIterable {
        case club
        case bar
        case lounge
        case event
        case other
    }

    public let id: UUID
    public let name: String
    public let imageName: String
    public let type: VenueType
    public let description: String
    public let latitude: Double
    public let longitude: Double
    public let address: String
    public let workingHours: String

    public init(
        id: UUID,
        name: String,
        imageName: String = "",
        type: VenueType,
        description: String = "",
        latitude: Double,
        longitude: Double,
        address: String = "",
        workingHours: String = ""
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.type = type
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.workingHours = workingHours
    }

    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (-90.0...90.0).contains(latitude) &&
            (-180.0...180.0).contains(longitude)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageName
        case type
        case description
        case latitude
        case longitude
        case address
        case workingHours
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        imageName = try c.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        type = try c.decode(VenueType.self, forKey: .type)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        latitude = try c.decode(Double.self, forKey: .latitude)
        longitude = try c.decode(Double.self, forKey: .longitude)
        address = try c.decodeIfPresent(String.self, forKey: .address) ?? ""
        workingHours = try c.decodeIfPresent(String.self, forKey: .workingHours) ?? ""
    }
}

public typealias Venue = VenueCore
