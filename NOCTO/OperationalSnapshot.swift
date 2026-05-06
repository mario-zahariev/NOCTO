import Foundation
import NOCTOCore

struct VenueTypeSignal: Identifiable {
    let id: String
    let label: String
    let count: Int
}

enum ConfidenceSource: Equatable {
    case hardData
    case mixedData
    case softData

    var label: String {
        switch self {
        case .hardData: return "Твърд източник"
        case .mixedData: return "Смесен източник"
        case .softData: return "Мек източник"
        }
    }
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
    private let venues: [Venue]

    init(
        loadLatencyMs: Int,
        didLoadSucceed: Bool,
        lastErrorMessage: String?,
        venues: [Venue]
    ) {
        self.venues = venues
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
        didLoadSucceed ? "Изряден" : "Проблем"
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
        switch confidenceScore {
        case 90...: return "Пълна"
        case 70...: return "Стабилна"
        case 60...: return "Ограничена"
        default: return "Ниска"
        }
    }

    var confidenceSource: ConfidenceSource {
        if let confidenceOverride = Self.confidenceOverride {
            return confidenceOverride.source ?? Self.sourceFromScore(confidenceOverride.score)
        }

        if didLoadSucceed, lastErrorMessage == nil, dataCompletenessPercent >= 95, venuesCount >= 8 {
            return .hardData
        }
        if didLoadSucceed, dataCompletenessPercent >= 70, venuesCount >= 4 {
            return .mixedData
        }
        return .softData
    }

    var confidenceScore: Int {
        if let confidenceOverride = Self.confidenceOverride {
            return confidenceOverride.score
        }

        switch confidenceSource {
        case .hardData:
            return 100
        case .mixedData:
            return mixedConfidenceScore
        case .softData:
            return softConfidenceScore
        }
    }

    var confidenceValidationLabel: String {
        "Валидация: \(signalConfidenceLabel) (\(confidenceScore)%)"
    }

    var trafficIndex: Int {
        let venueScore = min(venuesCount * 5, 50)
        let lateNightScore = min(lateNightVenueCount * 6, 30)
        let completenessScore = dataCompletenessPercent / 5
        let latencyPenalty = min(loadLatencyMs / 25, 30)
        let reliabilityBonus = didLoadSucceed ? 20 : 0
        return max(0, min(100, venueScore + lateNightScore + completenessScore - latencyPenalty + reliabilityBonus))
    }

    var bestAfterTime: String {
        var openingHourCounts: [Int: Int] = [:]

        for venue in venues {
            guard let opening = Self.hourAndMinute(from: venue.workingHours, at: 0) else { continue }
            openingHourCounts[opening.hour, default: 0] += 1
        }

        guard
            let modalOpeningHour = openingHourCounts.max(by: { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key > rhs.key
                }
                return lhs.value < rhs.value
            })?.key
        else {
            return "—"
        }

        return "After \(String(format: "%02d", modalOpeningHour)):00"
    }

    private var mixedConfidenceScore: Int {
        let completeness = clamped(dataCompletenessPercent, min: 70, max: 100)
        let completenessBoost = Int(((Double(completeness - 70) / 30.0) * 12.0).rounded())

        let coverage = clamped(venuesCount, min: 4, max: 12)
        let coverageBoost = Int(((Double(coverage - 4) / 8.0) * 6.0).rounded())

        let latency = clamped(loadLatencyMs, min: 0, max: 220)
        let latencyBoost = Int(((Double(220 - latency) / 220.0) * 2.0).rounded())

        return clamped(70 + completenessBoost + coverageBoost + latencyBoost, min: 70, max: 90)
    }

    private var softConfidenceScore: Int {
        let loadBonus = didLoadSucceed ? 10 : 0
        let completenessBoost = Int(((Double(clamped(dataCompletenessPercent, min: 0, max: 70)) / 70.0) * 10.0).rounded())
        let coverageBoost = min(venuesCount, 4)
        let latencyPenalty = Int(((Double(clamped(loadLatencyMs, min: 120, max: 520) - 120) / 400.0) * 9.0).rounded())

        return clamped(35 + loadBonus + completenessBoost + coverageBoost - latencyPenalty, min: 20, max: 59)
    }

    private func clamped(_ value: Int, min lower: Int, max upper: Int) -> Int {
        Swift.max(lower, Swift.min(value, upper))
    }

    private static func label(for type: Venue.VenueType) -> String {
        switch type {
        case .club: return "Клубове"
        case .bar: return "Барове"
        case .lounge: return "Лаундж"
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

    private struct ConfidenceOverride {
        let score: Int
        let source: ConfidenceSource?
    }

    private static var confidenceOverride: ConfidenceOverride? {
        #if DEBUG
        if let debugPinnedConfidenceScore {
            return ConfidenceOverride(
                score: clamped(debugPinnedConfidenceScore, min: 0, max: 100),
                source: .softData
            )
        }
        #endif

        let environment = ProcessInfo.processInfo.environment
        let arguments = ProcessInfo.processInfo.arguments

        let forcedScoreRaw = environment["NOCTO_FORCE_CONFIDENCE"] ??
            arguments.first(where: { $0.hasPrefix("--nocto-force-confidence=") })?
                .replacingOccurrences(of: "--nocto-force-confidence=", with: "")
        guard let forcedScoreRaw, let forcedScore = Int(forcedScoreRaw) else {
            return nil
        }

        let forcedSourceRaw = environment["NOCTO_FORCE_SOURCE"] ??
            arguments.first(where: { $0.hasPrefix("--nocto-force-source=") })?
                .replacingOccurrences(of: "--nocto-force-source=", with: "")

        return ConfidenceOverride(
            score: clamped(forcedScore, min: 0, max: 100),
            source: sourceFromRaw(forcedSourceRaw)
        )
    }

    private static func sourceFromRaw(_ raw: String?) -> ConfidenceSource? {
        guard let raw else { return nil }
        let normalized = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalized.contains("hard") || normalized.contains("твърд") {
            return .hardData
        }
        if normalized.contains("mixed") || normalized.contains("смес") {
            return .mixedData
        }
        if normalized.contains("soft") || normalized.contains("мек") {
            return .softData
        }
        return nil
    }

    private static func sourceFromScore(_ score: Int) -> ConfidenceSource {
        switch score {
        case 90...: return .hardData
        case 70...: return .mixedData
        default: return .softData
        }
    }

    private static func clamped(_ value: Int, min lower: Int, max upper: Int) -> Int {
        Swift.max(lower, Swift.min(value, upper))
    }

    // Keep nil by default; use NOCTO_FORCE_CONFIDENCE / --nocto-force-confidence for QA scenarios.
    private static let debugPinnedConfidenceScore: Int? = nil

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
