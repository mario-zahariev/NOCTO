import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct NoctoAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        enum IntegrityState: String, Codable, Hashable {
            case live = "LIVE"
            case offlineLowConfidence = "OFFLINE - LOW CONFIDENCE"

            var bannerLabel: String {
                switch self {
                case .live:
                    return "ЛОКАЛЕН СИГНАЛ"
                case .offlineLowConfidence:
                    return "ОФЛАЙН · НИСКА УВЕРЕНОСТ"
                }
            }
        }

        let confidenceScore: Int
        let confidenceLabel: String
        let sourceLabel: String
        let activeVenueCount: Int
        let lateNightVenueCount: Int
        let integrityState: IntegrityState
        let updatedAt: Date
    }

    let sessionID: String
    let city: String
}
