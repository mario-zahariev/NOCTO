import SwiftUI
import NOCTOCore

struct VenueCard: View {
    let venue: Venue
    let isFavorite: Bool
    let badge: NOCTOVenueBadge?
    let onToggleFavorite: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            NoctoEnergyRail(tint: badge == .quietPick ? NoctoTheme.ultraviolet : NoctoTheme.accent)
                .padding(.vertical, 18)
                .padding(.leading, 1)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    HStack(spacing: 7) {
                        Text("ЛОКАЛЕН ПУЛС")
                            .font(.caption2.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(NoctoTheme.accent)

                        Circle()
                            .fill(NoctoTheme.accent.opacity(0.72))
                            .frame(width: 4, height: 4)

                        Text(venue.type.cardLabel)
                            .font(.caption2.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(NoctoTheme.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .noctoSurface(.embeddedPocket, cornerRadius: 18, tint: NoctoTheme.accent)

                    Spacer(minLength: 8)

                    Button(action: onToggleFavorite) {
                        Text("✦")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(isFavorite ? NoctoTheme.accent : NoctoTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(isFavorite ? NoctoTheme.accent.opacity(0.16) : NoctoTheme.surfaceEmbedded.opacity(0.86))
                            )
                            .shadow(color: isFavorite ? NoctoTheme.accent.opacity(0.18) : .clear, radius: 10, x: 0, y: 0)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isFavorite ? "Премахни от любими" : "Добави в любими")
                }

                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text(venue.name)
                        .font(.title2.weight(.black))
                        .foregroundStyle(NoctoTheme.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    NoctoSignalWave(
                        tint: NoctoTheme.accent.opacity(0.92),
                        secondary: NoctoTheme.ultraviolet.opacity(0.82),
                        compact: true
                    )
                    .frame(width: 46, height: 24)
                }

                VStack(alignment: .leading, spacing: 9) {
                    VenueSignalRow(kind: .pulse, title: "Пулс", value: pulseValue, tint: NoctoTheme.accent)

                    if let badge {
                        VenueSignalRow(kind: .wave, title: "Вълна", value: badge.cardValue, tint: NoctoTheme.ultraviolet)
                    }

                    VenueSignalRow(kind: .node, title: "Място", value: venue.address, tint: NoctoTheme.textSecondary)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        venueBadge(text: venue.type.cardLabel, tint: NoctoTheme.accent, accessibilityLabel: "Тип: \(venue.type.cardLabel)")
                        venueBadge(text: "работи \(venue.workingHours)", tint: NoctoTheme.ultraviolet, accessibilityLabel: "Работно време: \(venue.workingHours)")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        venueBadge(text: venue.type.cardLabel, tint: NoctoTheme.accent, accessibilityLabel: "Тип: \(venue.type.cardLabel)")
                        venueBadge(text: "работи \(venue.workingHours)", tint: NoctoTheme.ultraviolet, accessibilityLabel: "Работно време: \(venue.workingHours)")
                    }
                }
            }
            .padding(.leading, 6)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .noctoSurface(.raised, cornerRadius: 16)
    }

    private var pulseValue: String {
        if let closeRange = venue.signalLabel.range(of: "Клуб · До ") {
            let time = venue.signalLabel[closeRange.upperBound...]
            return "силен · до \(time)"
        }

        if let startRange = venue.signalLabel.range(of: "Най-силно след ") {
            let time = venue.signalLabel[startRange.upperBound...]
            return "най-силно · след \(time)"
        }

        return venue.signalLabel
    }

    private func venueBadge(
        text: String,
        tint: Color,
        accessibilityLabel: String
    ) -> some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(tint)
                .frame(width: 12, height: 4)

            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .noctoSurface(.embeddedPocket, cornerRadius: 18, tint: tint)
        .accessibilityLabel(accessibilityLabel)
    }
}

private extension NOCTOVenueBadge {
    var cardValue: String {
        switch self {
        case .closesAt(let time): return "до \(time)"
        case .startsAt(let time): return "след \(time)"
        case .lateWave: return "късна"
        case .quietPick: return "тиха"
        }
    }
}

private struct VenueSignalRow: View {
    enum Kind {
        case pulse
        case wave
        case node
    }

    let kind: Kind
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VenueSignalGlyph(kind: kind, tint: tint)
                .frame(width: 16, height: 16)

            Text(title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(NoctoTheme.textPrimary)

            Text(value)
                .font(.footnote)
                .foregroundStyle(NoctoTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct VenueSignalGlyph: View {
    let kind: VenueSignalRow.Kind
    let tint: Color

    var body: some View {
        ZStack {
            switch kind {
            case .pulse:
                HStack(spacing: 2) {
                    ForEach([8.0, 14.0, 10.0], id: \.self) { height in
                        Capsule()
                            .fill(tint)
                            .frame(width: 3, height: height)
                    }
                }

            case .wave:
                Circle()
                    .trim(from: 0.12, to: 0.88)
                    .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-35))

                Circle()
                    .fill(tint)
                    .frame(width: 4, height: 4)

            case .node:
                Circle()
                    .stroke(tint.opacity(0.86), lineWidth: 2)
                    .frame(width: 13, height: 13)

                Circle()
                    .fill(tint)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

private extension VenueCore.VenueType {
    var cardLabel: String {
        switch self {
        case .club: return "КЛУБ"
        case .bar: return "БАР"
        case .lounge: return "ЛАУНДЖ"
        case .event: return "СЪБИТИЕ"
        case .other: return "ДРУГО"
        }
    }
}
