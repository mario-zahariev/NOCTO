import SwiftUI
import NOCTOCore

struct VenueDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let venue: Venue

    var body: some View {
        GeometryReader { proxy in
            let scale = NoctoHTML.scale(for: proxy.size)

            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                NoctoHTMLStatusBar(scale: scale, compactSignal: true)
                    .zIndex(25)

                NoctoDetailHeader(scale: scale)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 13 * scale) {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Text("← Назад")
                                    .font(.system(size: 7 * scale, weight: .bold))
                                    .tracking(2 * scale)
                                    .textCase(.uppercase)
                                    .foregroundStyle(NoctoTheme.textTertiary)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            HStack(spacing: 5 * scale) {
                                Circle()
                                    .fill(NoctoTheme.accent)
                                    .frame(width: 6 * scale, height: 6 * scale)

                                Text("Live now")
                                    .font(.system(size: 7 * scale, weight: .bold))
                                    .tracking(2 * scale)
                                    .textCase(.uppercase)
                                    .foregroundStyle(NoctoTheme.accent)
                            }
                        }

                        VStack(alignment: .leading, spacing: 3 * scale) {
                            Text("Yalta Club")
                                .font(.system(size: 22 * scale, weight: .heavy))
                                .tracking(-0.3 * scale)
                                .foregroundStyle(NoctoTheme.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)

                            Text("Techno · Dark Electro · Berlin Rave")
                                .font(.system(size: 7 * scale, weight: .bold))
                                .tracking(3 * scale)
                                .textCase(.uppercase)
                                .foregroundStyle(NoctoTheme.accent)
                                .lineLimit(1)
                                .minimumScaleFactor(0.55)
                        }

                        NoctoCircularPulseMeter(scale: scale)

                        NoctoMomentsGrid(scale: scale)

                        NoctoInfoTable(scale: scale)

                        Button {
                            Haptics.tap()
                        } label: {
                            Text("Виж гост листа · Take me there ↗")
                                .font(.system(size: 9 * scale, weight: .heavy))
                                .tracking(3 * scale)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.58)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13 * scale)
                                .background(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    NoctoTheme.accent,
                                                    Color(hex: "#C93A68")
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .noctoSignalGlow(.hot)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16 * scale)
                    .padding(.top, (165 + 14) * scale)
                    .padding(.bottom, 132 * scale)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }

            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct NoctoDetailHeader: View {
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Color(hex: "#21060F"),
                    Color(hex: "#260711"),
                    Color(hex: "#10070C")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            NoctoCrestView()
                .frame(width: 38 * scale, height: 38 * scale)
                .padding(.top, 26 * scale)
                .padding(.leading, 16 * scale)

            NoctoDetailAtmosphereBars(scale: scale)
                .frame(height: 56 * scale)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 178 * scale)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

private struct NoctoDetailAtmosphereBars: View {
    let scale: CGFloat

    private let heights: [CGFloat] = [21, 42, 29, 52, 35, 45, 25, 48, 32, 39]

    var body: some View {
        HStack(alignment: .bottom, spacing: 3 * scale) {
            ForEach(Array(heights.enumerated()), id: \.offset) { index, height in
                RoundedRectangle(cornerRadius: 3 * scale)
                    .fill(index.isMultiple(of: 2) ? NoctoTheme.accent.opacity(0.22) : NoctoTheme.accentLight.opacity(0.28))
                    .frame(maxWidth: .infinity)
                    .frame(height: height * scale)
            }
        }
        .padding(.horizontal, 16 * scale)
    }
}

private struct NoctoCircularPulseMeter: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 14 * scale) {
            ZStack {
                Circle()
                    .fill(NoctoTheme.accent.opacity(0.06))
                    .overlay(
                        Circle()
                            .stroke(NoctoTheme.accent.opacity(0.10), lineWidth: 1.5 * scale)
                    )

                Circle()
                    .trim(from: 0, to: 0.82)
                    .stroke(
                        NoctoTheme.accent,
                        style: StrokeStyle(lineWidth: 5 * scale, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: NoctoTheme.accent.opacity(0.70), radius: 3 * scale)

                NoctoPulseWave()
                    .stroke(NoctoTheme.accent.opacity(0.35), lineWidth: 1.5 * scale)
                    .frame(width: 64 * scale, height: 18 * scale)

                VStack(spacing: 1 * scale) {
                    Text("82%")
                        .font(.system(size: 16 * scale, weight: .heavy))
                        .foregroundStyle(NoctoTheme.textPrimary)

                    Text("ПУЛС")
                        .font(.system(size: 6 * scale, weight: .bold))
                        .tracking(2 * scale)
                        .foregroundStyle(NoctoTheme.textSecondary)
                }
                .offset(y: 6 * scale)
            }
            .frame(width: 88 * scale, height: 88 * scale)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text("Атмосфера")
                    .font(.system(size: 7 * scale, weight: .bold))
                    .tracking(3 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(NoctoTheme.textTertiary)

                Text("Full and\nbuzzing")
                    .font(.system(size: 10 * scale, weight: .bold))
                    .lineSpacing(1 * scale)
                    .foregroundStyle(NoctoTheme.textPrimary)

                Text("Crowd 80–120 · 23:00–06:00")
                    .font(.system(size: 8 * scale, weight: .regular))
                    .foregroundStyle(NoctoTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14 * scale)
        .padding(.vertical, 12 * scale)
        .background(
            RoundedRectangle(cornerRadius: 14 * scale)
                .fill(NoctoTheme.accent.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14 * scale)
                .stroke(NoctoTheme.accent.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct NoctoPulseWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / 10
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))

        for index in 0..<10 {
            let x1 = rect.minX + step * CGFloat(index) + step * 0.5
            let x2 = rect.minX + step * CGFloat(index + 1)
            let controlY = index.isMultiple(of: 2) ? rect.minY : rect.maxY
            path.addQuadCurve(to: CGPoint(x: x2, y: rect.midY), control: CGPoint(x: x1, y: controlY))
        }

        return path
    }
}

private struct NoctoMomentsGrid: View {
    let scale: CGFloat

    private let moments: [MomentKind] = [.dance, .live, .dance, .chill, .dance, .empty, .chill, .dance, .empty, .live, .dance, .chill]

    var body: some View {
        VStack(alignment: .leading, spacing: 7 * scale) {
            Text("Моменти · 23:14")
                .font(.system(size: 7 * scale, weight: .bold))
                .tracking(3 * scale)
                .textCase(.uppercase)
                .foregroundStyle(NoctoTheme.textTertiary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3 * scale), count: 6), spacing: 3 * scale) {
                ForEach(Array(moments.enumerated()), id: \.offset) { _, moment in
                    RoundedRectangle(cornerRadius: 5 * scale)
                        .fill(moment.fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5 * scale)
                                .stroke(moment.border, lineWidth: 1)
                        )
                        .overlay(alignment: .topTrailing) {
                            if let dot = moment.dot {
                                Circle()
                                    .fill(dot)
                                    .frame(width: 4 * scale, height: 4 * scale)
                                    .padding(4 * scale)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                }
            }

            HStack(spacing: 12 * scale) {
                legend("Dance", color: NoctoTheme.accent)
                legend("Live", color: NoctoTheme.gold)
                legend("Chill", color: NoctoTheme.signalAfter)
            }
        }
    }

    private func legend(_ text: String, color: Color) -> some View {
        HStack(spacing: 4 * scale) {
            RoundedRectangle(cornerRadius: 2 * scale)
                .fill(color)
                .frame(width: 6 * scale, height: 6 * scale)

            Text(text)
                .font(.system(size: 6 * scale, weight: .bold))
                .tracking(1 * scale)
                .textCase(.uppercase)
                .foregroundStyle(NoctoTheme.textTertiary)
        }
    }
}

private enum MomentKind {
    case dance
    case live
    case chill
    case empty

    var dot: Color? {
        switch self {
        case .dance: return NoctoTheme.accent
        case .live: return NoctoTheme.gold
        case .chill: return NoctoTheme.signalAfter
        case .empty: return nil
        }
    }

    var fill: LinearGradient {
        switch self {
        case .dance:
            return LinearGradient(colors: [NoctoTheme.accent.opacity(0.22), NoctoTheme.accent.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .live:
            return LinearGradient(colors: [NoctoTheme.gold.opacity(0.18), NoctoTheme.gold.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .chill:
            return LinearGradient(colors: [NoctoTheme.signalAfter.opacity(0.12), NoctoTheme.signalAfter.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .empty:
            return LinearGradient(colors: [Color.white.opacity(0.02), Color.white.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var border: Color {
        switch self {
        case .dance: return NoctoTheme.accent.opacity(0.22)
        case .live: return NoctoTheme.gold.opacity(0.20)
        case .chill: return NoctoTheme.signalAfter.opacity(0.15)
        case .empty: return Color.white.opacity(0.03)
        }
    }
}

private struct NoctoInfoTable: View {
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            infoRow("Вход", "15 лв. след 01:00")
            infoRow("Музика", "Techno · Electro", tint: NoctoTheme.accent)
            infoRow("Crowd", "Mixed 25–35")
            infoRow("Гост листа", "Достъпна ✓", tint: NoctoTheme.gold, last: true)
        }
    }

    private func infoRow(_ key: String, _ value: String, tint: Color = NoctoTheme.textPrimary, last: Bool = false) -> some View {
        HStack {
            Text(key)
                .font(.system(size: 7 * scale, weight: .bold))
                .tracking(2 * scale)
                .textCase(.uppercase)
                .foregroundStyle(NoctoTheme.textTertiary)

            Spacer()

            Text(value)
                .font(.system(size: 9 * scale, weight: .bold))
                .foregroundStyle(tint)
        }
        .padding(.vertical, 7 * scale)
        .overlay(alignment: .bottom) {
            if !last {
                Rectangle()
                    .fill(Color.white.opacity(0.04))
                    .frame(height: 1)
            }
        }
    }
}

private struct NoctoDetailHTMLBottomNav: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            item(label: "Пулс", active: false, kind: .home)
            item(label: "Карта", active: false, kind: .map)
            item(label: "Запазени", active: true, kind: .bookmark)
            item(label: "Профил", active: false, kind: .profile)
        }
        .frame(height: 52 * scale)
        .padding(.horizontal, 6 * scale)
        .background(
            RoundedRectangle(cornerRadius: 18 * scale)
                .fill(Color(hex: "#080412").opacity(0.93))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18 * scale)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func item(label: String, active: Bool, kind: NavKind) -> some View {
        VStack(spacing: 3 * scale) {
            navIcon(kind: kind, active: active)
                .frame(width: 18 * scale, height: 18 * scale)
                .opacity(active ? 1 : 0.28)

            Text(label)
                .font(.system(size: 6 * scale, weight: .bold))
                .tracking(1.5 * scale)
                .textCase(.uppercase)
                .foregroundStyle(active ? NoctoTheme.accent : NoctoTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10 * scale)
        .padding(.vertical, 4 * scale)
    }

    @ViewBuilder
    private func navIcon(kind: NavKind, active: Bool) -> some View {
        let tint = active ? NoctoTheme.accent : Color.white

        switch kind {
        case .home:
            Path { path in
                path.move(to: CGPoint(x: 2, y: 8))
                path.addLine(to: CGPoint(x: 9, y: 2))
                path.addLine(to: CGPoint(x: 16, y: 8))
                path.addLine(to: CGPoint(x: 16, y: 17))
                path.addLine(to: CGPoint(x: 12, y: 17))
                path.addLine(to: CGPoint(x: 12, y: 12))
                path.addLine(to: CGPoint(x: 6, y: 12))
                path.addLine(to: CGPoint(x: 6, y: 17))
                path.addLine(to: CGPoint(x: 2, y: 17))
                path.closeSubpath()
            }
            .stroke(tint, lineWidth: active ? 1.8 : 1.5)
            .background {
                if active {
                    Path { path in
                        path.move(to: CGPoint(x: 2, y: 8))
                        path.addLine(to: CGPoint(x: 9, y: 2))
                        path.addLine(to: CGPoint(x: 16, y: 8))
                        path.addLine(to: CGPoint(x: 16, y: 17))
                        path.addLine(to: CGPoint(x: 12, y: 17))
                        path.addLine(to: CGPoint(x: 12, y: 12))
                        path.addLine(to: CGPoint(x: 6, y: 12))
                        path.addLine(to: CGPoint(x: 6, y: 17))
                        path.addLine(to: CGPoint(x: 2, y: 17))
                        path.closeSubpath()
                    }
                    .fill(tint.opacity(0.10))
                }
            }
        case .map:
            Circle().stroke(tint, lineWidth: active ? 1.8 : 1.5)
            Circle().stroke(tint, lineWidth: 1.5).frame(width: 6 * scale, height: 6 * scale)
        case .bookmark:
            BookmarkIcon()
                .stroke(tint, style: StrokeStyle(lineWidth: active ? 1.8 : 1.5, lineJoin: .round))
                .background {
                    if active {
                        BookmarkIcon().fill(tint.opacity(0.10))
                    }
                }
        case .profile:
            VStack(spacing: 2 * scale) {
                Circle().stroke(tint, lineWidth: 1.5).frame(width: 8 * scale, height: 8 * scale)
                Path { path in
                    path.move(to: CGPoint(x: 2, y: 16))
                    path.addCurve(to: CGPoint(x: 16, y: 16), control1: CGPoint(x: 3, y: 10), control2: CGPoint(x: 15, y: 10))
                }
                .stroke(tint, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            }
        }
    }

    private enum NavKind {
        case home
        case map
        case bookmark
        case profile
    }
}

private struct BookmarkIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.79, y: rect.height * 0.88))
        path.addLine(to: CGPoint(x: rect.width * 0.50, y: rect.height * 0.71))
        path.addLine(to: CGPoint(x: rect.width * 0.21, y: rect.height * 0.88))
        path.addLine(to: CGPoint(x: rect.width * 0.21, y: rect.height * 0.21))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.29, y: rect.height * 0.13),
            control1: CGPoint(x: rect.width * 0.21, y: rect.height * 0.17),
            control2: CGPoint(x: rect.width * 0.25, y: rect.height * 0.13)
        )
        path.addLine(to: CGPoint(x: rect.width * 0.71, y: rect.height * 0.13))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.79, y: rect.height * 0.21),
            control1: CGPoint(x: rect.width * 0.75, y: rect.height * 0.13),
            control2: CGPoint(x: rect.width * 0.79, y: rect.height * 0.17)
        )
        path.closeSubpath()
        return path
    }
}
