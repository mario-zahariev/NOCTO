import Foundation
import NOCTOCore

struct VenueTypeSignal: Identifiable {
    let id: String
    let label: String
    let count: Int
}

struct OperationalSnapshot {
    let loadLatencyMs: Int
    let didLoadSucceed: Bool
    let lastErrorMessage: String?
    let venuesCount: Int
    let lateNightVenueCount: Int
    let dataCompletenessPercent: Int
    let primaryVenueTypeLabel: String
    let typeSignals: [VenueTypeSignal]

    init(
        loadLatencyMs: Int,
        didLoadSucceed: Bool,
        lastErrorMessage: String?,
        venues: [Venue]
    ) {
        self.loadLatencyMs = loadLatencyMs
        self.didLoadSucceed = didLoadSucceed
        self.lastErrorMessage = lastErrorMessage
        self.venuesCount = venues.count
        self.lateNightVenueCount = venues.filter(Self.isLateNightVenue).count
        self.dataCompletenessPercent = Self.dataCompletenessPercent(for: venues)

        let grouped = Dictionary(grouping: venues, by: \.type)
        let sortedTypes = Venue.VenueType.allCases.map { type in
            VenueTypeSignal(
                id: type.rawValue,
                label: Self.label(for: type),
                count: grouped[type, default: []].count
            )
        }
        .filter { $0.count > 0 }
        .sorted { lhs, rhs in
            if lhs.count == rhs.count { return lhs.label < rhs.label }
            return lhs.count > rhs.count
        }

        self.typeSignals = sortedTypes
        self.primaryVenueTypeLabel = sortedTypes.first?.label ?? "Няма данни"
    }

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

    var lateNightAvailabilityLabel: String {
        switch lateNightVenueCount {
        case 6...: return "Силна"
        case 3...: return "Добра"
        case 1...: return "Ограничена"
        default: return "Няма"
        }
    }

    var signalConfidenceLabel: String {
        guard didLoadSucceed else { return "Ниска" }
        if venuesCount >= 10 && dataCompletenessPercent >= 90 {
            return "Висока"
        }
        if venuesCount >= 6 && dataCompletenessPercent >= 70 {
            return "Средна"
        }
        return "Ниска"
    }

    var trafficIndex: Int {
        let venueScore = min(venuesCount * 5, 50)
        let lateNightScore = min(lateNightVenueCount * 6, 30)
        let completenessScore = dataCompletenessPercent / 5
        let latencyPenalty = min(loadLatencyMs / 25, 30)
        let reliabilityBonus = didLoadSucceed ? 20 : 0
        return max(0, min(100, venueScore + lateNightScore + completenessScore - latencyPenalty + reliabilityBonus))
    }

    private static func label(for type: Venue.VenueType) -> String {
        switch type {
        case .club: return "Клубове"
        case .bar: return "Барове"
        case .lounge: return "Lounge"
        case .event: return "Събития"
        case .other: return "Други"
        }
    }

    private static func dataCompletenessPercent(for venues: [Venue]) -> Int {
        guard !venues.isEmpty else { return 0 }

        let filledFields = venues.reduce(0) { total, venue in
            total +
                fieldScore(venue.name) +
                fieldScore(venue.imageName) +
                fieldScore(venue.description) +
                fieldScore(venue.address) +
                fieldScore(venue.workingHours) +
                (venue.isValid ? 1 : 0)
        }

        return Int((Double(filledFields) / Double(venues.count * 6) * 100).rounded())
    }

    private static func fieldScore(_ value: String) -> Int {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 1
    }

    private static func isLateNightVenue(_ venue: Venue) -> Bool {
        guard
            let opening = hourAndMinute(from: venue.workingHours, at: 0),
            let closing = hourAndMinute(from: venue.workingHours, at: 1)
        else {
            return false
        }

        let closesNextDay = closing.hour < opening.hour ||
            (closing.hour == opening.hour && closing.minute <= opening.minute)
        let closingMinuteOfDay = closing.hour * 60 + closing.minute
        return closesNextDay && (180..<720).contains(closingMinuteOfDay)
    }

    private static func hourAndMinute(from workingHours: String, at index: Int) -> (hour: Int, minute: Int)? {
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

        return (hour, minute)
    }
}
