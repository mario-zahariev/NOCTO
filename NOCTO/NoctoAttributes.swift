import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct NoctoAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        enum IntegrityState: String, Codable, Hashable {
            case live = "LIVE"
            case offlineLowConfidence = "OFFLINE - LOW CONFIDENCE"
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

@available(iOS 16.1, *)
extension NoctoAttributes.ContentState {
    static var lowConfidenceLabel: String {
        localized("low_confidence_label", defaultValue: "Low")
    }

    static var softSourceLabel: String {
        localized("soft_source_label", defaultValue: "Soft Source")
    }

    static var offlineLowConfidenceDisplayText: String {
        localized("offline_low_confidence_display_text", defaultValue: "Offline - Low Confidence")
    }

    static var signalStrengthAccessibilityLabel: String {
        localized("signal_strength_accessibility_label", defaultValue: "Signal Strength")
    }

    private static func localized(_ key: String, defaultValue: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: .main, value: defaultValue, comment: "")
    }
}
