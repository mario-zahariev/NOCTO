import SwiftUI
import NOCTOCore

struct VenueCard: View {
    let venue: Venue
    let isFavorite: Bool
    let badge: NOCTOVenueBadge?
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(venue.type.cardLabel)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(NoctoTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(NoctoTheme.cardBorder.opacity(0.36))
                    .clipShape(Capsule())

                Spacer(minLength: 8)

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isFavorite ? NoctoTheme.accent : NoctoTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(NoctoTheme.cardBorder.opacity(0.36))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Премахни от любими" : "Добави в любими")
            }

            Text(venue.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(NoctoTheme.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                VenueMetaRow(icon: "mappin.and.ellipse", text: venue.address)
                VenueMetaRow(icon: "clock", text: "Работно време: \(venue.workingHours)")
            }

            HStack(spacing: 8) {
                venueBadge(
                    icon: "waveform.path.ecg",
                    text: venue.signalLabel,
                    tint: NoctoTheme.accent,
                    accessibilityLabel: "Сигнал: \(venue.signalLabel)"
                )

                if let badge {
                    venueBadge(
                        icon: badge.systemImage,
                        text: badge.label,
                        tint: NoctoTheme.ultraviolet,
                        accessibilityLabel: "Насока: \(badge.label)"
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NoctoTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(NoctoTheme.cardBorder, lineWidth: 1)
        )
        .microFeedback()
    }

    private func venueBadge(
        icon: String,
        text: String,
        tint: Color,
        accessibilityLabel: String
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.14))
        .clipShape(Capsule())
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct VenueMetaRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(NoctoTheme.accent)
                .frame(width: 14, alignment: .leading)

            Text(text)
                .font(.footnote)
                .foregroundStyle(NoctoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
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
