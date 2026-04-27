import Foundation
import Combine

@MainActor
final class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteIDs: Set<UUID>

    private let storageKey = "com.nocto.favoriteVenueIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let rawIDs = defaults.array(forKey: storageKey) as? [String] {
            self.favoriteIDs = Set(rawIDs.compactMap(UUID.init(uuidString:)))
        } else {
            self.favoriteIDs = []
        }
    }

    func isFavorite(_ venueID: UUID) -> Bool {
        favoriteIDs.contains(venueID)
    }

    func toggle(_ venueID: UUID) {
        if favoriteIDs.contains(venueID) {
            favoriteIDs.remove(venueID)
        } else {
            favoriteIDs.insert(venueID)
        }
        save()
    }

    private func save() {
        let payload = favoriteIDs.map(\.uuidString).sorted()
        defaults.set(payload, forKey: storageKey)
    }
}
