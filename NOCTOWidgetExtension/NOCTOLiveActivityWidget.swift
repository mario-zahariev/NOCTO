import ActivityKit
import SwiftUI
import WidgetKit

@main
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
                Image(systemName: iconName(for: context.state))
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

    private func iconName(for state: NoctoAttributes.ContentState) -> String {
        if state.sourceLabel.contains("Твърд") {
            return "bolt.fill"
        }
        if state.sourceLabel.contains("Смесен") {
            return "dial.medium.fill"
        }
        return "waveform.slash"
    }
}

private struct LockScreenSignalView: View {
    let state: NoctoAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if state.integrityState == .offlineLowConfidence {
                Text("OFFLINE - LOW CONFIDENCE")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PulseActivityPalette.neutral)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(state.activeVenueCount)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseActivityPalette.textPrimary)
                    Text("активни обекта")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PulseActivityPalette.textSecondary)
                }

                SignalProgressBar(value: state.confidenceScore, active: true)
                Text("Валидация: \(state.sourceLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PulseActivityPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
}

private struct ExpandedSignalHubView: View {
    let state: NoctoAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if state.integrityState == .offlineLowConfidence {
                Text("OFFLINE - LOW CONFIDENCE")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PulseActivityPalette.neutral)
            } else {
                SignalProgressBar(value: state.confidenceScore, active: true)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(state.activeVenueCount)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseActivityPalette.textPrimary)
                    Text("активни обекта")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PulseActivityPalette.textSecondary)
                }
                Text("Валидация: \(state.sourceLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PulseActivityPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SignalProgressBar: View {
    let value: Int
    let active: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(PulseActivityPalette.track)
                Capsule()
                    .fill(active ? PulseActivityPalette.ultraviolet : PulseActivityPalette.neutral)
                    .frame(width: proxy.size.width * CGFloat(max(0, min(value, 100))) / 100.0)
            }
        }
        .frame(height: 4)
    }
}

private enum PulseActivityPalette {
    static let ultraviolet = Color(red: 124.0 / 255.0, green: 92.0 / 255.0, blue: 1.0)
    static let neutral = Color(red: 142.0 / 255.0, green: 149.0 / 255.0, blue: 160.0 / 255.0)
    static let surface = Color.black
    static let track = Color.white.opacity(0.14)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 154.0 / 255.0, green: 163.0 / 255.0, blue: 178.0 / 255.0)
}
