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

    public var signalLabel: String {
        if type == .club, let closingTime = Self.normalizedTime(from: workingHours, at: 1) {
            return Self.clampedLabel("Клуб · До \(closingTime)")
        }

        if let openingTime = Self.normalizedTime(from: workingHours, at: 0) {
            return Self.clampedLabel("Най-силно след \(openingTime)")
        }

        return Self.fallbackLabel(for: type)
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        type = try container.decode(VenueType.self, forKey: .type)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        workingHours = try container.decodeIfPresent(String.self, forKey: .workingHours) ?? ""
    }

    private static func fallbackLabel(for type: VenueType) -> String {
        switch type {
        case .club: return "Клуб късна вълна"
        case .bar: return "Бар вечерен ритъм"
        case .lounge: return "Лаундж късен флоу"
        case .event: return "Събитие тази вечер"
        case .other: return "Нощен сигнал"
        }
    }

    private static func clampedLabel(_ label: String) -> String {
        guard label.count > 30 else { return label }
        return String(label.prefix(30))
    }

    public static func hourMinuteTuple(from workingHours: String, at index: Int) -> (h: Int, m: Int)? {
        let parts = workingHours.split(separator: "-")
        guard parts.indices.contains(index) else { return nil }

        let timeParts = parts[index]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":")

        guard
            timeParts.count == 2,
            let hour = Int(timeParts[0].trimmingCharacters(in: .whitespacesAndNewlines)),
            let minute = Int(timeParts[1].trimmingCharacters(in: .whitespacesAndNewlines)),
            (0...23).contains(hour),
            (0...59).contains(minute)
        else {
            return nil
        }

        return (h: hour, m: minute)
    }

    private static func normalizedTime(from workingHours: String, at index: Int) -> String? {
        guard let tuple = hourMinuteTuple(from: workingHours, at: index) else { return nil }
        return String(format: "%02d:%02d", tuple.h, tuple.m)
    }
}

public typealias Venue = VenueCore
