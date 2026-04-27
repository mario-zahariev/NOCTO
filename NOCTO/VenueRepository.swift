import NOCTOCore
import Foundation

typealias VenueRepositoryError = LocalVenueRepositoryError

struct VenueRepository {
    private let core = LocalVenueRepository()

    func loadVenues() async throws -> [Venue] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    continuation.resume(returning: try core.loadVenues())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
