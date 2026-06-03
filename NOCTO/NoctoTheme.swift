import SwiftUI

enum NoctoTheme {
    static let background = Color(hex: "#050609")
    static let surfaceBase = Color(hex: "#0B101B")
    static let surfaceRaised = Color(hex: "#101827")
    static let surfaceHero = Color(hex: "#131B2B")
    static let surfaceEmbedded = Color(hex: "#080C14")
    static let card = surfaceRaised
    static let cardBorder = Color(hex: "#232A37")
    static let accent = Color(hex: "#FD5B8A")
    static let ultraviolet = Color(hex: "#7C5CFF")
    static let ember = Color(hex: "#C8814A")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#9AA3B2")
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
    static let violetBloom = NoctoTheme.ultraviolet.opacity(0.10)
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
            materialFill(NoctoTheme.surfaceRaised, bloom: 0.12)

        case .hero:
            materialFill(NoctoTheme.surfaceHero, bloom: 0.24)

        case .floatingBar:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(NoctoTheme.background.opacity(0.76))
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
        case .hero: return 0.075
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
    var secondary: Color = NoctoTheme.ultraviolet
    var compact = false

    private var bars: [CGFloat] {
        compact ? [8, 15, 11, 22, 14, 18] : [10, 18, 13, 28, 17, 24, 12, 20, 15]
    }

    var body: some View {
        HStack(alignment: .center, spacing: compact ? 3 : 4) {
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
                    .frame(width: compact ? 3 : 4, height: height)
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
