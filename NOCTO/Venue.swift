import Foundation
import CoreLocation

struct Venue: Identifiable, Codable, Equatable {
    enum VenueType: String, Codable, CaseIterable {
        case club
        case bar
        case lounge
        case event
        case other
    }

    let id: UUID
    let name: String
    let imageName: String
    let type: VenueType
    let description: String
    let latitude: Double
    let longitude: Double
    let address: String
    let workingHours: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (-90.0...90.0).contains(latitude) &&
            (-180.0...180.0).contains(longitude)
    }
}
