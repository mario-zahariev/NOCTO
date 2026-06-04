import SwiftUI

enum NoctoTheme {
    enum Colors {
        static let bgBase = Color(hex: "#0A0A0C")
        static let surface = Color(hex: "#141416")
        static let surfaceElevated = Color(hex: "#1C1C1F")
        static let borderSoft = Color(hex: "#2C2C30")
        static let borderHot = Color(hex: "#FF2E63")
        static let glass = Color.white.opacity(0.04)

        static let accentPink = Color(hex: "#FF2E63")
        static let accentCyan = Color(hex: "#00D4FF")
        static let accentPurple = Color(hex: "#A855F7")
        static let accentGold = Color(hex: "#EAB308")

        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "#9CA3AF")
    }

    enum Radius {
        static let card: CGFloat = 14
        static let modal: CGFloat = 18
        static let tabBar: CGFloat = 24
        static let small: CGFloat = 8
    }

    enum Glow {
        case none
        case active
        case hot
        case live
    }

    static let background = Colors.bgBase
    static let backgroundWine = Color(hex: "#10070C")
    static let backgroundEvent = Color(hex: "#05030B")
    static let backgroundAfter = Color(hex: "#050414")
    static let surfaceBase = Colors.surface
    static let surfaceRaised = Colors.surfaceElevated
    static let surfaceHero = Color(hex: "#21060F")
    static let surfaceEmbedded = Color(hex: "#08040D")
    static let card = surfaceRaised
    static let cardBorder = Colors.borderSoft
    static let accent = Colors.accentPink
    static let accentLight = Color(hex: "#FF7FA0")
    static let event = Colors.accentPurple
    static let gold = Colors.accentGold
    static let afterhoursBlue = Colors.accentPurple
    static let signalAfter = Colors.accentCyan
    static let signalDead = Color(hex: "#343343")
    static let ultraviolet = afterhoursBlue
    static let ember = gold
    static let textPrimary = Colors.textPrimary
    static let textSecondary = Colors.textSecondary
    static let textTertiary = Color(hex: "#5F6672")

    static var cityBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [
                    background,
                    backgroundWine,
                    Color(hex: "#16060D"),
                    background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    accent.opacity(0.24),
                    accent.opacity(0.055),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 24,
                endRadius: 360
            )

            RadialGradient(
                colors: [
                    afterhoursBlue.opacity(0.12),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 36,
                endRadius: 430
            )
        }
    }
}

private struct NoctoSurfaceModifier: ViewModifier {
    let fill: Color
    let border: Color
    let cornerRadius: CGFloat
    let shadowOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 14, x: 0, y: 8)
    }
}

private struct NoctoSignalGlowModifier: ViewModifier {
    let level: NoctoTheme.Glow

    @ViewBuilder
    func body(content: Content) -> some View {
        switch level {
        case .none:
            content

        case .active:
            content
                .shadow(color: NoctoTheme.Colors.accentPink.opacity(0.18), radius: 3, x: 0, y: 0)
                .shadow(color: NoctoTheme.Colors.accentPink.opacity(0.32), radius: 8, x: 0, y: 0)

        case .hot:
            content
                .shadow(color: NoctoTheme.Colors.accentPink.opacity(0.22), radius: 4, x: 0, y: 1)
                .shadow(color: NoctoTheme.Colors.accentPink.opacity(0.52), radius: 14, x: 0, y: 0)

        case .live:
            content
                .shadow(color: NoctoTheme.Colors.accentCyan.opacity(0.20), radius: 4, x: 0, y: 1)
                .shadow(color: NoctoTheme.Colors.accentCyan.opacity(0.42), radius: 11, x: 0, y: 0)
        }
    }
}

private struct NoctoGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(NoctoTheme.Colors.glass)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(NoctoTheme.Colors.borderSoft.opacity(0.30), lineWidth: 0.5)
            )
    }
}

extension View {
    func noctoSurface(cornerRadius: CGFloat = NoctoTheme.Radius.card) -> some View {
        modifier(
            NoctoSurfaceModifier(
                fill: NoctoTheme.Colors.surface,
                border: NoctoTheme.Colors.borderSoft.opacity(0.70),
                cornerRadius: cornerRadius,
                shadowOpacity: 0.18
            )
        )
    }

    func noctoElevatedSurface(cornerRadius: CGFloat = NoctoTheme.Radius.card) -> some View {
        modifier(
            NoctoSurfaceModifier(
                fill: NoctoTheme.Colors.surfaceElevated,
                border: NoctoTheme.Colors.borderSoft.opacity(0.85),
                cornerRadius: cornerRadius,
                shadowOpacity: 0.30
            )
        )
    }

    func noctoSignalGlow(_ level: NoctoTheme.Glow) -> some View {
        modifier(NoctoSignalGlowModifier(level: level))
    }

    func noctoGlass(cornerRadius: CGFloat = NoctoTheme.Radius.card) -> some View {
        modifier(NoctoGlassModifier(cornerRadius: cornerRadius))
    }
}

enum NoctoVenueState: Equatable {
    case hot
    case event
    case afterhours
    case steady

    var accent: Color {
        switch self {
        case .hot: return NoctoTheme.accent
        case .event: return NoctoTheme.gold
        case .afterhours: return NoctoTheme.signalAfter
        case .steady: return NoctoTheme.accentLight
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .hot: return NoctoTheme.accentLight
        case .event: return NoctoTheme.event
        case .afterhours: return NoctoTheme.afterhoursBlue
        case .steady: return NoctoTheme.accent
        }
    }

    var label: String {
        switch self {
        case .hot: return "Горещо"
        case .event: return "Event"
        case .afterhours: return "Afterhours"
        case .steady: return "Стабилно"
        }
    }

    var badgeText: String {
        switch self {
        case .hot: return "●●● горещо"
        case .event: return "★ special"
        case .afterhours: return "after 01:30"
        case .steady: return "live"
        }
    }

    var atmosphereText: String {
        switch self {
        case .hot: return "Full and buzzing"
        case .event: return "Special set tonight"
        case .afterhours: return "Locals' secret"
        case .steady: return "Good flow"
        }
    }

    var pulseScore: Int {
        switch self {
        case .hot: return 96
        case .event: return 88
        case .afterhours: return 74
        case .steady: return 67
        }
    }
}

enum NoctoHTML {
    static let baseWidth: CGFloat = 288
    static let baseHeight: CGFloat = 596

    static func scale(for size: CGSize) -> CGFloat {
        size.width / baseWidth
    }
}

struct NoctoChromeHiddenPreferenceKey: PreferenceKey {
    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func noctoHidesRootChrome(_ hidden: Bool) -> some View {
        preference(key: NoctoChromeHiddenPreferenceKey.self, value: hidden)
    }
}

struct NoctoHTMLStatusBar: View {
    let scale: CGFloat
    var compactSignal = false

    var body: some View {
        HStack(alignment: .bottom) {
            Text("23:14")
                .font(.system(size: 12 * scale, weight: .bold))
                .tracking(0.5 * scale)
                .foregroundStyle(NoctoTheme.textPrimary)

            Spacer()

            HStack(spacing: 5 * scale) {
                if !compactSignal {
                    NoctoSignalIcon(scale: scale)
                        .frame(width: 16 * scale, height: 10 * scale)
                }

                NoctoBatteryIcon(scale: scale)
                    .frame(width: 15 * scale, height: 10 * scale)
            }
        }
        .frame(height: 50 * scale, alignment: .bottom)
        .padding(.horizontal, 22 * scale)
        .padding(.bottom, 8 * scale)
        .allowsHitTesting(false)
    }
}

private struct NoctoSignalIcon: View {
    let scale: CGFloat

    var body: some View {
        HStack(alignment: .bottom, spacing: 1 * scale) {
            RoundedRectangle(cornerRadius: 1 * scale)
                .fill(Color.white.opacity(0.4))
                .frame(width: 3 * scale, height: 6 * scale)
            RoundedRectangle(cornerRadius: 1 * scale)
                .fill(Color.white.opacity(0.6))
                .frame(width: 3 * scale, height: 8 * scale)
            RoundedRectangle(cornerRadius: 1 * scale)
                .fill(Color.white.opacity(0.8))
                .frame(width: 3 * scale, height: 10 * scale)
            RoundedRectangle(cornerRadius: 1 * scale)
                .fill(Color.white)
                .frame(width: 3 * scale, height: 10 * scale)
        }
    }
}

private struct NoctoBatteryIcon: View {
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2 * scale)
                .stroke(Color.white.opacity(0.5), lineWidth: 1 * scale)
                .frame(width: 12 * scale, height: 9 * scale)

            RoundedRectangle(cornerRadius: 1.5 * scale)
                .fill(Color.white)
                .frame(width: 9 * scale, height: 7 * scale)
                .padding(.leading, 1.5 * scale)

            RoundedRectangle(cornerRadius: 1 * scale)
                .fill(Color.white.opacity(0.4))
                .frame(width: 2 * scale, height: 4 * scale)
                .offset(x: 13 * scale)
        }
    }
}

struct NoctoCrestView: View {
    var tint: Color = NoctoTheme.accent
    var eventDot: Color?

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let scale = side / 1024

            ZStack {
                RoundedRectangle(cornerRadius: 256 * scale)
                    .fill(NoctoTheme.background)

                NoctoCrestGlyph()
                    .fill(tint)

                if let eventDot {
                    Circle()
                        .fill(eventDot)
                        .frame(width: 116 * scale, height: 116 * scale)
                        .position(x: 780 * scale, y: 246 * scale)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct NoctoCrestGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x / 1024, y: rect.minY + rect.height * y / 1024)
        }

        var path = Path()

        path.move(to: p(288, 212))
        path.addCurve(to: p(124, 512), control1: p(184, 286), control2: p(124, 396))
        path.addCurve(to: p(288, 812), control1: p(124, 626), control2: p(184, 738))
        path.addLine(to: p(335, 760))
        path.addCurve(to: p(222, 512), control1: p(264, 702), control2: p(222, 613))
        path.addCurve(to: p(335, 264), control1: p(222, 411), control2: p(264, 322))
        path.closeSubpath()

        path.move(to: p(736, 212))
        path.addCurve(to: p(900, 512), control1: p(840, 286), control2: p(900, 396))
        path.addCurve(to: p(736, 812), control1: p(900, 626), control2: p(840, 738))
        path.addLine(to: p(689, 760))
        path.addCurve(to: p(802, 512), control1: p(760, 702), control2: p(802, 613))
        path.addCurve(to: p(689, 264), control1: p(802, 411), control2: p(760, 322))
        path.closeSubpath()

        path.move(to: p(312, 738))
        path.addLine(to: p(312, 310))
        path.addLine(to: p(410, 262))
        path.addLine(to: p(410, 738))
        path.closeSubpath()

        path.move(to: p(398, 262))
        path.addLine(to: p(493, 262))
        path.addLine(to: p(712, 738))
        path.addLine(to: p(617, 738))
        path.closeSubpath()

        path.move(to: p(614, 286))
        path.addLine(to: p(712, 286))
        path.addLine(to: p(712, 714))
        path.addLine(to: p(614, 762))
        path.closeSubpath()

        return path
    }
}

struct NoctoHTMLVUBars: View {
    let scale: CGFloat
    var small = false
    var state: NoctoVenueState = .hot

    private var bars: [CGFloat] {
        if small {
            switch state {
            case .hot: return [12, 20, 14]
            case .event: return [10, 17, 12]
            case .afterhours: return [6, 8, 4]
            case .steady: return [9, 13, 10]
            }
        }

        return [18.7, 29.9, 14.3, 25.5, 32.6, 20.4, 16.3, 27.9, 11.9, 23.8, 30.6, 17.7]
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: (small ? 2 : 4) * scale) {
            ForEach(Array(bars.enumerated()), id: \.offset) { index, height in
                let barWidth: CGFloat? = small ? 5 * scale : nil

                RoundedRectangle(cornerRadius: (small ? 2 : 3) * scale)
                    .fill(barColor(index: index))
                    .frame(width: barWidth, height: height * scale)
                    .frame(maxWidth: small ? nil : .infinity)
            }
        }
        .frame(height: (small ? 22 : 34) * scale, alignment: .bottom)
        .accessibilityHidden(true)
    }

    private func barColor(index: Int) -> Color {
        if small {
            switch state {
            case .hot: return NoctoTheme.accent
            case .event: return NoctoTheme.gold
            case .afterhours: return Color(hex: "#2B2750")
            case .steady: return NoctoTheme.accentLight
            }
        }

        return index.isMultiple(of: 2) ? NoctoTheme.accent : NoctoTheme.accentLight
    }
}

enum NoctoSurfaceLevel {
    case background
    case base
    case raised
    case hero
    case floatingBar
    case embeddedPocket
    case active
}

enum NoctoMaterialTokens {
    static let topSheen = Color.white.opacity(0.055)
    static let shadow = Color.black.opacity(0.42)
    static let accentBloom = NoctoTheme.accent.opacity(0.16)
    static let violetBloom = NoctoTheme.afterhoursBlue.opacity(0.10)
}

struct NoctoGlow: View {
    let tint: Color
    var strength: Double = 1

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    tint.opacity(0.16 * strength),
                    tint.opacity(0.045 * strength),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 260
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.045 * strength),
                    .clear,
                    Color.black.opacity(0.10 * strength)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .allowsHitTesting(false)
    }
}

struct NoctoSurfaceStyle: ViewModifier {
    let level: NoctoSurfaceLevel
    var cornerRadius: CGFloat = 18
    var tint: Color = NoctoTheme.accent

    func body(content: Content) -> some View {
        content
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: NoctoMaterialTokens.shadow.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }

    @ViewBuilder
    private var surface: some View {
        switch level {
        case .background:
            NoctoTheme.background

        case .base:
            materialFill(NoctoTheme.surfaceBase, bloom: 0.03)

        case .raised:
            materialFill(NoctoTheme.surfaceRaised, bloom: 0.16)

        case .hero:
            materialFill(NoctoTheme.surfaceHero, bloom: 0.32)

        case .floatingBar:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(NoctoTheme.surfaceEmbedded.opacity(0.92))
                )
                .overlay(NoctoGlow(tint: tint, strength: 0.72).clipShape(RoundedRectangle(cornerRadius: cornerRadius)))

        case .embeddedPocket:
            materialFill(NoctoTheme.surfaceEmbedded, bloom: 0.035)

        case .active:
            materialFill(NoctoTheme.surfaceRaised, bloom: 0.28)
        }
    }

    private func materialFill(_ color: Color, bloom: Double) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .overlay(NoctoGlow(tint: tint, strength: bloom / 0.12).clipShape(RoundedRectangle(cornerRadius: cornerRadius)))
            .overlay(alignment: .topLeading) {
                LinearGradient(
                    colors: [
                        Color.white.opacity(highlightOpacity),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .allowsHitTesting(false)
            }
    }

    private var highlightOpacity: Double {
        switch level {
        case .hero: return 0.06
        case .floatingBar: return 0.05
        case .embeddedPocket: return 0.025
        case .active: return 0.065
        default: return 0.045
        }
    }

    private var shadowOpacity: Double {
        switch level {
        case .background, .embeddedPocket: return 0
        case .base: return 0.16
        case .raised: return 0.50
        case .hero: return 0.62
        case .floatingBar: return 0.70
        case .active: return 0.36
        }
    }

    private var shadowRadius: CGFloat {
        switch level {
        case .background, .embeddedPocket: return 0
        case .base: return 12
        case .raised: return 18
        case .hero: return 28
        case .floatingBar: return 24
        case .active: return 16
        }
    }

    private var shadowOffset: CGFloat {
        switch level {
        case .background, .embeddedPocket: return 0
        case .base: return 6
        case .raised: return 10
        case .hero: return 14
        case .floatingBar: return 10
        case .active: return 5
        }
    }
}

extension View {
    func noctoSurface(
        _ level: NoctoSurfaceLevel,
        cornerRadius: CGFloat = 18,
        tint: Color = NoctoTheme.accent
    ) -> some View {
        modifier(NoctoSurfaceStyle(level: level, cornerRadius: cornerRadius, tint: tint))
    }
}

struct NoctoSignalWave: View {
    var tint: Color = NoctoTheme.accent
    var secondary: Color = NoctoTheme.accentLight
    var compact = false
    var intense = false

    private var bars: [CGFloat] {
        if intense {
            return [22, 36, 17, 30, 40, 24, 19, 34, 15, 28, 37, 21]
        }
        return compact ? [8, 15, 11, 22, 14, 18] : [10, 18, 13, 28, 17, 24, 12, 20, 15]
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: compact ? 3 : 4) {
            ForEach(Array(bars.enumerated()), id: \.offset) { index, height in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                index.isMultiple(of: 2) ? tint : secondary,
                                (index.isMultiple(of: 2) ? tint : secondary).opacity(0.42)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: compact ? 3 : (intense ? 7 : 4), height: height)
                    .shadow(color: (index.isMultiple(of: 2) ? tint : secondary).opacity(0.18), radius: 5, x: 0, y: 0)
            }
        }
        .allowsHitTesting(false)
    }
}

struct NoctoEnergyRail: View {
    var tint: Color = NoctoTheme.accent

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        tint.opacity(0.42),
                        NoctoTheme.ultraviolet.opacity(0.26),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 3)
            .blur(radius: 0.2)
            .shadow(color: tint.opacity(0.25), radius: 10, x: 0, y: 0)
            .allowsHitTesting(false)
    }
}
