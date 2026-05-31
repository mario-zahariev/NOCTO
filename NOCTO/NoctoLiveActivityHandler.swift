import ActivityKit
import Foundation
import os

@available(iOS 16.1, *)
@MainActor
final class NoctoLiveActivityHandler {
    static let shared = NoctoLiveActivityHandler()

    private static let activeStaleInterval: TimeInterval = 15 * 60
    private static let lowConfidenceDismissInterval: TimeInterval = 5 * 60
    private static let logger = Logger(subsystem: "com.mario.NOCTO", category: "LiveActivity")

    private var activity: Activity<NoctoAttributes>?
    private let sessionID = UUID().uuidString

    private init() {}

    func sync(with snapshot: OperationalSnapshot) async {
        if !Self.isEnabledForCurrentProcess {
            await cleanupActivitiesWhenDisabled()
            return
        }
        hydrateActivityIfNeeded()

        let state = NoctoAttributes.ContentState(snapshot: snapshot)
        #if DEBUG
        print("[NOCTO LiveActivity] score=\(state.confidenceScore) state=\(state.integrityState.rawValue) source=\(state.sourceLabel)")
        #endif
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            for current in Activity<NoctoAttributes>.activities {
                await end(current, using: state, dismissalPolicy: .immediate)
            }
            activity = nil
            return
        }

        if state.integrityState == .offlineLowConfidence {
            let dismissAt = Date().addingTimeInterval(Self.lowConfidenceDismissInterval)
            let currentActivities = Activity<NoctoAttributes>.activities

            guard !currentActivities.isEmpty else {
                activity = nil
                return
            }

            for current in currentActivities {
                await end(
                    current,
                    using: state,
                    dismissalPolicy: .after(dismissAt)
                )
            }

            activity = nil
            return
        }

        switch activity {
        case .none:
            await start(with: state)
        case .some:
            await update(with: state)
        }
    }

    private func cleanupActivitiesWhenDisabled() async {
        let state = NoctoAttributes.ContentState(
            confidenceScore: 0,
            confidenceLabel: "Ниска",
            sourceLabel: "Мек източник",
            activeVenueCount: 0,
            lateNightVenueCount: 0,
            integrityState: .offlineLowConfidence,
            updatedAt: Date()
        )

        for current in Activity<NoctoAttributes>.activities {
            await end(current, using: state, dismissalPolicy: .immediate)
        }

        activity = nil
    }

    private static var isEnabledForCurrentProcess: Bool {
        let environment = ProcessInfo.processInfo.environment
        let arguments = ProcessInfo.processInfo.arguments

        let envDisabled = environment["NOCTO_DISABLE_LIVE_ACTIVITY"] == "1"
        let argDisabled = arguments.contains("--nocto-disable-live-activity")
        return !(envDisabled || argDisabled)
    }

    private func hydrateActivityIfNeeded() {
        guard activity == nil else { return }
        activity = Activity<NoctoAttributes>.activities.first
    }

    private func start(with state: NoctoAttributes.ContentState) async {
        let attributes = NoctoAttributes(sessionID: sessionID, city: "София")
        let content = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(Self.activeStaleInterval),
            relevanceScore: 1.0
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            Self.logger.error("Activity.request failed: \(error.localizedDescription, privacy: .public)")
            activity = nil
        }
    }

    private func update(with state: NoctoAttributes.ContentState) async {
        guard let activity else { return }
        let content = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(Self.activeStaleInterval),
            relevanceScore: 1.0
        )
        await activity.update(content)
    }

    private func end(
        _ activity: Activity<NoctoAttributes>,
        using state: NoctoAttributes.ContentState,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async {
        let content = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(Self.lowConfidenceDismissInterval),
            relevanceScore: 0.1
        )
        await activity.end(content, dismissalPolicy: dismissalPolicy)
    }
}

@available(iOS 16.1, *)
private extension NoctoAttributes.ContentState {
    init(snapshot: OperationalSnapshot) {
        let isLowConfidence = snapshot.confidenceScore < 60
        self.confidenceScore = snapshot.confidenceScore
        self.confidenceLabel = snapshot.signalConfidenceLabel
        self.sourceLabel = snapshot.confidenceSource.label
        self.activeVenueCount = snapshot.venuesCount
        self.lateNightVenueCount = snapshot.lateNightVenueCount
        self.integrityState = isLowConfidence ? .offlineLowConfidence : .live
        self.updatedAt = Date()
    }
}
