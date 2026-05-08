import SwiftUI
import XCTest
@testable import NOCTO

@MainActor
@available(iOS 16.1, *)
final class LiveActivitySnapshotTests: SnapshotTestCase {
    func testLockScreenSignalView_offline59_snapshot() async {
        let state = VisualFixtures.offlineActivityState(score: 59)
        await assertSnapshot(
            of: lockScreenPreview(state: state),
            named: "offline_lock_59",
            viewport: .lockScreenCard
        )
    }

    func testLockScreenSignalView_live60_snapshot() async {
        let state = VisualFixtures.liveActivityState(score: 60)
        await assertSnapshot(
            of: lockScreenPreview(state: state),
            named: "live_lock_60",
            viewport: .lockScreenCard
        )
    }

    func testLockScreenSignalView_live92_snapshot() async {
        let state = VisualFixtures.liveActivityState(score: 92)
        await assertSnapshot(
            of: lockScreenPreview(state: state),
            named: "live_lock_92",
            viewport: .lockScreenCard
        )
    }

    func testLockScreenSignalView_live100_snapshot() async {
        let state = VisualFixtures.liveActivityState(score: 100)
        await assertSnapshot(
            of: lockScreenPreview(state: state),
            named: "live_lock_100",
            viewport: .lockScreenCard
        )
    }

    func testExpandedSignalHubView_live92_snapshot() async {
        let state = VisualFixtures.liveActivityState(score: 92)
        await assertSnapshot(
            of: expandedPreview(state: state),
            named: "live_expanded_92",
            viewport: .dynamicIslandExpanded
        )
    }

    func testExpandedSignalHubView_offline59_snapshot() async {
        let state = VisualFixtures.offlineActivityState(score: 59)
        await assertSnapshot(
            of: expandedPreview(state: state),
            named: "offline_expanded_59",
            viewport: .dynamicIslandExpanded
        )
    }

    private func lockScreenPreview(state: NoctoAttributes.ContentState) -> some View {
        LockScreenSignalView(state: state)
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(PulseActivityPalette.surface)
    }

    private func expandedPreview(state: NoctoAttributes.ContentState) -> some View {
        ExpandedSignalHubView(state: state)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(PulseActivityPalette.surface)
    }
}
