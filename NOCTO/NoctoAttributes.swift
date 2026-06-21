import ActivityKit
import Foundation

@available(iOS 16.1, *)
enum NoctoIntegrityState: String, Codable, Hashable {
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

@available(iOS 16.1, *)
struct NoctoAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let confidenceScore: Int
        let confidenceLabel: String
        let sourceLabel: String
        let activeVenueCount: Int
        let lateNightVenueCount: Int
        let integrityState: NoctoIntegrityState
        let updatedAt: Date
    }

    let sessionID: String
    let city: String
}
