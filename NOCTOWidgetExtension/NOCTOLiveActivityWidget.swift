import ActivityKit
import SwiftUI
import WidgetKit

@main
@available(iOSApplicationExtension 16.1, *)
struct NOCTOWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        NOCTOLiveActivityWidget()
    }
}

@available(iOS 16.1, *)
struct NOCTOLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NoctoAttributes.self) { context in
            LockScreenSignalView(state: context.state)
                .activityBackgroundTint(PulseActivityPalette.surface)
                .activitySystemActionForegroundColor(PulseActivityPalette.textPrimary)
        } dynamicIsland: { context in
            let isOffline = context.state.integrityState == .offlineLowConfidence
            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    ExpandedSignalHubView(state: context.state)
                }
            } compactLeading: {
                Text("\(context.state.confidenceScore)%")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isOffline ? PulseActivityPalette.neutral : PulseActivityPalette.ultraviolet)
            } compactTrailing: {
                Image(systemName: pulseActivityIconName(for: context.state))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isOffline ? PulseActivityPalette.neutral : PulseActivityPalette.ultraviolet)
            } minimal: {
                Circle()
                    .fill(isOffline ? PulseActivityPalette.neutral : PulseActivityPalette.ultraviolet)
                    .frame(width: 10, height: 10)
            }
            .keylineTint(isOffline ? PulseActivityPalette.neutral : PulseActivityPalette.ultraviolet)
        }
    }
}
