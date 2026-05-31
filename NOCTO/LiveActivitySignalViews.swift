import SwiftUI

@available(iOS 16.1, *)
func pulseActivityIconName(for state: NoctoAttributes.ContentState) -> String {
    switch state.integrityState {
    case .live:
        return state.confidenceScore >= 90 ? "bolt.fill" : "dial.medium.fill"
    case .offlineLowConfidence:
        return "waveform.slash"
    }
}

@available(iOS 16.1, *)
struct LockScreenSignalView: View {
    let state: NoctoAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if state.integrityState == .offlineLowConfidence {
                Text(state.integrityState.bannerLabel)
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

@available(iOS 16.1, *)
struct ExpandedSignalHubView: View {
    let state: NoctoAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if state.integrityState == .offlineLowConfidence {
                Text(state.integrityState.bannerLabel)
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

@available(iOS 16.1, *)
struct SignalProgressBar: View {
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

@available(iOS 16.1, *)
enum PulseActivityPalette {
    static let ultraviolet = Color(red: 124.0 / 255.0, green: 92.0 / 255.0, blue: 1.0)
    static let neutral = Color(red: 142.0 / 255.0, green: 149.0 / 255.0, blue: 160.0 / 255.0)
    static let surface = Color.black
    static let track = Color.white.opacity(0.14)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 154.0 / 255.0, green: 163.0 / 255.0, blue: 178.0 / 255.0)
}
