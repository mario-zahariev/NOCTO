import Foundation

struct OperationalSnapshot {
    let loadLatencyMs: Int
    let didLoadSucceed: Bool
    let lastErrorMessage: String?
    let venuesCount: Int

    var decodeHealthLabel: String {
        didLoadSucceed ? "OK" : "ERROR"
    }

    var fallbackLabel: String {
        lastErrorMessage == nil ? "Няма" : "Активиран"
    }

    var latencyBandLabel: String {
        switch loadLatencyMs {
        case ..<80: return "Ниска"
        case ..<200: return "Нормална"
        default: return "Повишена"
        }
    }

    var trafficIndex: Int {
        let venueScore = min(venuesCount * 8, 80)
        let latencyPenalty = min(loadLatencyMs / 25, 30)
        let reliabilityBonus = didLoadSucceed ? 20 : 0
        return max(0, min(100, venueScore - latencyPenalty + reliabilityBonus))
    }
}
