import Foundation
import NOCTOCore

struct VenueTypeSignal: Identifiable {
    let id: String
    let label: String
    let count: Int
}

enum NOCTOVenueBadge: Equatable {
    case closesAt(String)
    case startsAt(String)
    case lateWave
    case quietPick

    var label: String {
        switch self {
        case .closesAt(let time): return "До \(time)"
        case .startsAt(let time): return "След \(time)"
        case .lateWave: return "Късна вълна"
        case .quietPick: return "Тих избор"
        }
    }

    var systemImage: String {
        switch self {
        case .closesAt: return "moon.stars"
        case .startsAt: return "clock.badge"
        case .lateWave: return "waveform.path.ecg"
        case .quietPick: return "sparkles"
        }
    }
}

enum VenueSignalResolver {
    static func badge(for venue: Venue) -> NOCTOVenueBadge? {
        guard
            let opening = Venue.hourMinuteTuple(from: venue.workingHours, at: 0),
            let closing = Venue.hourMinuteTuple(from: venue.workingHours, at: 1)
        else {
            return nil
        }

        let openingMinutes = opening.h * 60 + opening.m
        let closingMinutes = closing.h * 60 + closing.m

        if closingMinutes < 3 * 60 {
            return .quietPick
        }

        if venue.type == .club {
            return .lateWave
        }

        if closingMinutes <= openingMinutes {
            return .closesAt(Self.formatted(closing))
        }

        return .startsAt(Self.formatted(opening))
    }

    private static func formatted(_ tuple: (h: Int, m: Int)) -> String {
        String(format: "%02d:%02d", tuple.h, tuple.m)
    }
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

    var lateNightCoverageHours: Int {
        venues.compactMap(Self.lateNightCoverageHours(for:)).max() ?? 0
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
            guard let opening = Venue.hourMinuteTuple(from: venue.workingHours, at: 0) else { continue }
            openingHourCounts[opening.h, default: 0] += 1
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

        return "след \(String(format: "%02d", modalOpeningHour)):00"
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
        #else
        return nil
        #endif
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

    nonisolated private static func isLateNightVenue(_ venue: Venue) -> Bool {
        guard
            let opening = Venue.hourMinuteTuple(from: venue.workingHours, at: 0),
            let closing = Venue.hourMinuteTuple(from: venue.workingHours, at: 1)
        else {
            return false
        }

        let closesNextDay = closing.h < opening.h ||
            (closing.h == opening.h && closing.m <= opening.m)
        let closingMinuteOfDay = closing.h * 60 + closing.m
        return closesNextDay && (180..<720).contains(closingMinuteOfDay)
    }

    nonisolated private static func lateNightCoverageHours(for venue: Venue) -> Int? {
        guard
            isLateNightVenue(venue),
            let opening = Venue.hourMinuteTuple(from: venue.workingHours, at: 0),
            let closing = Venue.hourMinuteTuple(from: venue.workingHours, at: 1)
        else {
            return nil
        }

        let openingMinutes = opening.h * 60 + opening.m
        var closingMinutes = closing.h * 60 + closing.m

        if closingMinutes <= openingMinutes {
            closingMinutes += 24 * 60
        }

        let durationMinutes = closingMinutes - openingMinutes
        guard durationMinutes > 0 else { return nil }
        return Int(ceil(Double(durationMinutes) / 60.0))
    }
}
