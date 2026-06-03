import SwiftUI

enum NoctoInstrumentTab: String, CaseIterable, Identifiable {
    case home
    case map
    case favorites
    case pulse
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            "Начало"
        case .map:
            "Карта"
        case .favorites:
            "Любими"
        case .pulse:
            "Пулс"
        case .profile:
            "Профил"
        }
    }

    var accessibilityLabel: String {
        "\(title) раздел"
    }
}

struct NoctoInstrumentTabShell<Content: View>: View {
    @Binding var selection: NoctoInstrumentTab
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 92)
                }

            NoctoInstrumentTabBar(selection: $selection)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private struct NoctoInstrumentTabBar: View {
    @Binding var selection: NoctoInstrumentTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(NoctoInstrumentTab.allCases) { tab in
                NoctoInstrumentTabButton(
                    tab: tab,
                    isActive: selection == tab,
                    action: {
                        guard selection != tab else { return }
                        selection = tab
                        Haptics.tap()
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 74)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(NoctoTheme.background.opacity(0.58))
                .background {
                    BlurView(style: .systemUltraThinMaterialDark)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.16),
                            NoctoTheme.accent.opacity(0.18),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(0.44), radius: 24, x: 0, y: 14)
        .shadow(color: NoctoTheme.accent.opacity(0.08), radius: 22, x: 0, y: 0)
    }
}

private struct NoctoInstrumentTabButton: View {
    let tab: NoctoInstrumentTab
    let isActive: Bool
    let action: () -> Void

    private var tint: Color {
        isActive ? NoctoTheme.accent : NoctoTheme.textSecondary.opacity(0.62)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    if isActive {
                        Circle()
                            .fill(NoctoTheme.accent.opacity(0.20))
                            .frame(width: 42, height: 42)
                            .blur(radius: 12)
                            .offset(y: 4)
                    }

                    NoctoInstrumentIcon(tab: tab, color: tint, isActive: isActive)
                        .frame(width: 30, height: 28)
                }
                .frame(height: 33)

                Text(tab.title)
                    .font(.system(size: 9.5, weight: isActive ? .semibold : .medium))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .scaleEffect(isActive ? 1.04 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.accessibilityLabel)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

private struct NoctoInstrumentIcon: View {
    let tab: NoctoInstrumentTab
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            switch tab {
            case .home:
                ApertureIcon(color: color, isActive: isActive)
            case .map:
                RadarIcon(color: color, isActive: isActive)
            case .favorites:
                QuantumStarIcon(color: color, isActive: isActive)
            case .pulse:
                VUMeterIcon(color: color, isActive: isActive)
            case .profile:
                IdentityGridIcon(color: color, isActive: isActive)
            }
        }
    }
}

private struct ApertureIcon: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.90)
                .stroke(color.opacity(isActive ? 0.95 : 0.72), style: StrokeStyle(lineWidth: 2.3, lineCap: .round))
                .rotationEffect(.degrees(104))
                .frame(width: 24, height: 24)

            Circle()
                .stroke(color.opacity(0.28), lineWidth: 1)
                .frame(width: 14, height: 14)

            Circle()
                .fill(color)
                .frame(width: 5.2, height: 5.2)
        }
    }
}

private struct RadarIcon: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(isActive ? 0.82 : 0.46), style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 4]))
                .frame(width: 25, height: 25)

            Circle()
                .stroke(color.opacity(isActive ? 0.72 : 0.38), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                .frame(width: 13, height: 13)

            Path { path in
                path.move(to: CGPoint(x: 15, y: 1))
                path.addLine(to: CGPoint(x: 15, y: 6))
                path.move(to: CGPoint(x: 15, y: 24))
                path.addLine(to: CGPoint(x: 15, y: 29))
                path.move(to: CGPoint(x: 1, y: 15))
                path.addLine(to: CGPoint(x: 6, y: 15))
                path.move(to: CGPoint(x: 24, y: 15))
                path.addLine(to: CGPoint(x: 29, y: 15))
            }
            .stroke(color.opacity(isActive ? 0.9 : 0.54), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))

            Circle()
                .fill(color)
                .frame(width: 3.6, height: 3.6)
                .offset(x: 4.5, y: -4.5)
        }
        .frame(width: 30, height: 30)
    }
}

private struct QuantumStarIcon: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(isActive ? 0.30 : 0.12), lineWidth: 1)
                .frame(width: 25, height: 25)

            Path { path in
                path.move(to: CGPoint(x: 15, y: 2.5))
                path.addLine(to: CGPoint(x: 18.6, y: 11.4))
                path.addLine(to: CGPoint(x: 27.5, y: 15))
                path.addLine(to: CGPoint(x: 18.6, y: 18.6))
                path.addLine(to: CGPoint(x: 15, y: 27.5))
                path.addLine(to: CGPoint(x: 11.4, y: 18.6))
                path.addLine(to: CGPoint(x: 2.5, y: 15))
                path.addLine(to: CGPoint(x: 11.4, y: 11.4))
                path.closeSubpath()
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.9, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(color.opacity(isActive ? 0.9 : 0.42))
                .frame(width: 3.2, height: 3.2)
        }
        .frame(width: 30, height: 30)
    }
}

private struct VUMeterIcon: View {
    let color: Color
    let isActive: Bool

    private let heights: [CGFloat] = [12, 20, 15, 23]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color.opacity(isActive ? 0.34 : 0.16))
                .frame(width: 27, height: 1)

            HStack(spacing: 3.2) {
                ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
                    Capsule()
                        .fill(color)
                        .frame(width: 3.2, height: height)
                }
            }

            VStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule()
                        .fill(color.opacity(0.42))
                        .frame(width: 4, height: 1)
                }
            }
            .offset(x: -15)
        }
        .frame(width: 30, height: 28)
    }
}

private struct IdentityGridIcon: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(color.opacity(isActive ? 0.92 : 0.56), lineWidth: 1.4)
                .frame(width: 24, height: 24)

            VStack(spacing: 2.8) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 2.8) {
                        ForEach(0..<3, id: \.self) { column in
                            Circle()
                                .fill(color.opacity(row == 1 && column == 1 ? 0.95 : 0.54))
                                .frame(width: 2.8, height: 2.8)
                        }
                    }
                }
            }

            Rectangle()
                .fill(color.opacity(isActive ? 0.82 : 0.36))
                .frame(width: 27, height: 1.2)
                .offset(y: isActive ? 4 : -4)
        }
        .frame(width: 30, height: 30)
    }
}
