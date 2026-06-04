import SwiftUI
import NOCTOCore

struct VenueCard: View {
    let venue: Venue
    let isFavorite: Bool
    let badge: NOCTOVenueBadge?
    let onToggleFavorite: () -> Void
    var scale: CGFloat = 1

    private var state: NoctoVenueState {
        venue.noctoState
    }

    private var cardRadius: CGFloat {
        NoctoTheme.Radius.card * scale
    }

    var body: some View {
        ZStack(alignment: state == .afterhours ? .bottomTrailing : .topTrailing) {
            RoundedRectangle(cornerRadius: cardRadius)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: cardRadius)
                        .stroke(borderColor, lineWidth: 1)
                )

            if state == .hot {
                Circle()
                    .fill(NoctoTheme.accent)
                    .frame(width: 6 * scale, height: 6 * scale)
                    .padding(9 * scale)
            }

            if state == .event {
                HStack(spacing: 4 * scale) {
                    Text("🎫")
                        .font(.system(size: 8 * scale))

                    Text("Tonight only")
                        .font(.system(size: 6 * scale, weight: .bold))
                        .tracking(1.5 * scale)
                        .textCase(.uppercase)
                        .foregroundStyle(NoctoTheme.gold)
                }
                .padding(.horizontal, 6 * scale)
                .padding(.vertical, 2 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 4 * scale)
                        .fill(NoctoTheme.gold.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4 * scale)
                        .stroke(NoctoTheme.gold.opacity(0.25), lineWidth: 1)
                )
                .padding(9 * scale)
            }

            if state == .afterhours {
                Circle()
                    .fill(NoctoTheme.signalAfter)
                    .frame(width: 6 * scale, height: 6 * scale)
                    .shadow(color: NoctoTheme.signalAfter.opacity(0.8), radius: 8 * scale)
                    .padding(9 * scale)
            }

            HStack(alignment: .center, spacing: 9 * scale) {
                NoctoHTMLVUBars(scale: scale, small: true, state: state)
                    .frame(width: 24 * scale, height: 22 * scale)

                VStack(alignment: .leading, spacing: 2 * scale) {
                    Text(venue.htmlCardName)
                        .font(.system(size: 11 * scale, weight: .heavy))
                        .tracking(0.2 * scale)
                        .foregroundStyle(state == .afterhours ? Color(hex: "#9A6E7E") : NoctoTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(venue.htmlCardSubtitle)
                        .font(.system(size: 7 * scale, weight: .semibold))
                        .tracking(1.5 * scale)
                        .textCase(.uppercase)
                        .foregroundStyle(state == .afterhours ? Color(hex: "#664250") : NoctoTheme.textTertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }

                Spacer(minLength: 6 * scale)

                Text(state.badgeText)
                    .font(.system(size: 7 * scale, weight: .bold))
                    .tracking(1 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(badgeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
                    .padding(.horizontal, 7 * scale)
                    .padding(.vertical, 3 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 4 * scale)
                            .fill(badgeColor.opacity(badgeOpacity))
                    )
            }
            .padding(.horizontal, 11 * scale)
            .padding(.vertical, 9 * scale)
        }
        .noctoSignalGlow(signalGlow)
        .contentShape(RoundedRectangle(cornerRadius: cardRadius))
    }

    private var cardFill: LinearGradient {
        switch state {
        case .hot:
            return LinearGradient(
                colors: [
                    NoctoTheme.accent.opacity(0.16),
                    NoctoTheme.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .event:
            return LinearGradient(
                colors: [
                    NoctoTheme.event.opacity(0.13),
                    NoctoTheme.gold.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .afterhours:
            return LinearGradient(
                colors: [
                    NoctoTheme.backgroundAfter.opacity(0.90),
                    NoctoTheme.backgroundAfter.opacity(0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .steady:
            return LinearGradient(
                colors: [
                    NoctoTheme.accent.opacity(0.08),
                    NoctoTheme.backgroundWine.opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderColor: Color {
        switch state {
        case .hot: return NoctoTheme.accent.opacity(0.20)
        case .event: return NoctoTheme.gold.opacity(0.22)
        case .afterhours: return NoctoTheme.afterhoursBlue.opacity(0.08)
        case .steady: return NoctoTheme.accent.opacity(0.12)
        }
    }

    private var badgeColor: Color {
        switch state {
        case .hot: return NoctoTheme.accent
        case .event: return NoctoTheme.gold
        case .afterhours: return Color(hex: "#8DCFC1")
        case .steady: return NoctoTheme.accentLight
        }
    }

    private var badgeOpacity: Double {
        switch state {
        case .event: return 0.12
        case .afterhours: return 0.06
        default: return 0.15
        }
    }

    private var signalGlow: NoctoTheme.Glow {
        switch state {
        case .hot: return .hot
        case .event, .afterhours: return .live
        case .steady: return .none
        }
    }
}

extension Venue {
    var noctoState: NoctoVenueState {
        if type == .event {
            return .event
        }

        guard let badge = VenueSignalResolver.badge(for: self) else {
            return type == .club ? .hot : .steady
        }

        switch badge {
        case .quietPick:
            return .afterhours
        case .lateWave:
            return .hot
        case .closesAt:
            return type == .club ? .hot : .afterhours
        case .startsAt:
            return .steady
        }
    }

    var htmlCardName: String {
        switch noctoState {
        case .hot: return "Yalta Club"
        case .event: return "Fabric Sofia"
        case .afterhours: return "Underground"
        case .steady: return "Mascot"
        }
    }

    var htmlCardSubtitle: String {
        switch noctoState {
        case .hot: return "Techno · 380m · Pulse 96%"
        case .event: return "Festival mode · 650m"
        case .afterhours: return "tiny bar · locals' secret"
        case .steady: return "Cocktails · 540m · Pulse 67%"
        }
    }

    var noctoDistanceLabel: String {
        switch noctoState {
        case .hot: return "380m"
        case .event: return "650m"
        case .afterhours: return "1.2km"
        case .steady: return "540m"
        }
    }

    var noctoGenreLine: String {
        switch noctoState {
        case .hot: return "Techno · Dark Electro · Berlin Rave"
        case .event: return "Festival mode · Guest Set"
        case .afterhours: return "tiny bar · locals' secret"
        case .steady: return "Cocktails · Social Crowd"
        }
    }
}
