import SwiftUI
import NOCTOCore
import MapKit

struct VenueDetailView: View {
    let venue: Venue
    @ObservedObject var favorites: FavoritesManager

    @State private var cameraPosition: MapCameraPosition

    private var isFavorite: Bool {
        favorites.isFavorite(venue.id)
    }

    private var badge: NOCTOVenueBadge? {
        VenueSignalResolver.badge(for: venue)
    }

    init(venue: Venue, favorites: FavoritesManager) {
        self.venue = venue
        self.favorites = favorites
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: venue.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VenueDetailHero(
                    venue: venue,
                    badge: badge,
                    isFavorite: isFavorite,
                    onToggleFavorite: toggleFavorite
                )

                VenueDetailSection(title: "Защо сега") {
                    Text(venue.whyNowCopy)
                        .font(.body)
                        .foregroundStyle(NoctoTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VenueDetailSection(title: "План за вечерта") {
                    VStack(spacing: 14) {
                        VenueDetailRow(
                            icon: "waveform.path.ecg",
                            title: "Сигнал",
                            value: venue.signalLabel,
                            tint: NoctoTheme.accent
                        )
                        VenueDetailRow(
                            icon: "clock",
                            title: "Работно време",
                            value: venue.timeWindowLabel,
                            tint: NoctoTheme.ultraviolet
                        )
                        VenueDetailRow(
                            icon: "sparkles",
                            title: "Вайб",
                            value: venue.type.vibeLabel,
                            tint: NoctoTheme.accent
                        )
                    }
                }

                VenueDetailSection(title: "Локация") {
                    VStack(alignment: .leading, spacing: 14) {
                        Map(position: $cameraPosition) {
                            Marker(venue.name, coordinate: venue.coordinate)
                                .tint(NoctoTheme.accent)
                        }
                        .frame(height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(NoctoTheme.cardBorder, lineWidth: 1)
                        )

                        VenueDetailRow(
                            icon: "mappin.and.ellipse",
                            title: "Адрес",
                            value: venue.address,
                            tint: NoctoTheme.accent
                        )
                    }
                }

                VenueDetailSection(title: "Сигнален контекст") {
                    VStack(spacing: 14) {
                        VenueDetailRow(
                            icon: "tag",
                            title: "Тип",
                            value: venue.type.detailLabel,
                            tint: NoctoTheme.ultraviolet
                        )
                        VenueDetailRow(
                            icon: "checkmark.seal",
                            title: "Основа",
                            value: venue.isValid ? "Валидиран локален запис" : "Запис за проверка",
                            tint: NoctoTheme.accent
                        )
                        VenueDetailRow(
                            icon: "moon.stars",
                            title: "Ритъм",
                            value: venue.rhythmLabel,
                            tint: NoctoTheme.ultraviolet
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(NoctoTheme.background.ignoresSafeArea())
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleFavorite() {
        favorites.toggle(venue.id)
        Haptics.tap()
    }
}

private struct VenueDetailHero: View {
    let venue: Venue
    let badge: NOCTOVenueBadge?
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 10) {
                VenueDetailPill(
                    icon: "tag",
                    text: venue.type.detailLabel,
                    tint: NoctoTheme.ultraviolet
                )

                if let badge {
                    VenueDetailPill(
                        icon: badge.systemImage,
                        text: badge.label,
                        tint: NoctoTheme.accent
                    )
                }

                Spacer(minLength: 8)

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isFavorite ? NoctoTheme.accent : NoctoTheme.textSecondary)
                        .frame(width: 42, height: 42)
                        .background(NoctoTheme.cardBorder.opacity(0.36))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Премахни от любими" : "Добави в любими")
            }

            Text(venue.name)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(NoctoTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(venue.description)
                .font(.body)
                .foregroundStyle(NoctoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VenueDetailPill(
                icon: "waveform.path.ecg",
                text: venue.signalLabel,
                tint: NoctoTheme.accent
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NoctoTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(NoctoTheme.cardBorder, lineWidth: 1)
        )
        .microFeedback()
    }
}

private struct VenueDetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(NoctoTheme.textPrimary)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NoctoTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(NoctoTheme.cardBorder, lineWidth: 1)
        )
    }
}

private struct VenueDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NoctoTheme.textSecondary)

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(NoctoTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

private struct VenueDetailPill: View {
    let icon: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))

            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.14))
        .clipShape(Capsule())
    }
}

private extension Venue {
    var timeWindowLabel: String {
        guard let openingTime, let closingTime else {
            return workingHours.isEmpty ? "Няма работно време" : workingHours
        }

        return "\(openingTime) - \(closingTime)"
    }

    var rhythmLabel: String {
        guard let opening = Self.hourMinuteTuple(from: workingHours, at: 0),
              let closing = Self.hourMinuteTuple(from: workingHours, at: 1)
        else {
            return type.rhythmFallback
        }

        let closesNextDay = closing.h < opening.h ||
            (closing.h == opening.h && closing.m <= opening.m)

        if closing.h < 3 || (closesNextDay && closing.h >= 5) {
            return "Късен прозорец"
        }

        if opening.h >= 22 {
            return "След тъмно"
        }

        return type.rhythmFallback
    }

    var whyNowCopy: String {
        switch VenueSignalResolver.badge(for: self) {
        case .closesAt(let time):
            return "По-силен избор за ранната част на вечерта. " +
                "Локалният график затваря около \(time), затова решението трябва да е навреме."
        case .startsAt(let time):
            return "Сигналът започва около \(time). " +
                "Мястото има повече смисъл след началото на вечерния прозорец."
        case .lateWave:
            return "Клубен формат с късна вълна. " +
                "Подходящо е, когато вечерта вече е набрала темпо и търсиш по-висока енергия."
        case .quietPick:
            return "По-тих избор спрямо късните клубни места. " +
                "Подходящо е, ако искаш по-контролирана вечер без излишен шум."
        case .none:
            return type.whyNowFallback
        }
    }

    private var openingTime: String? {
        normalizedTime(at: 0)
    }

    private var closingTime: String? {
        normalizedTime(at: 1)
    }

    private func normalizedTime(at index: Int) -> String? {
        guard let tuple = Self.hourMinuteTuple(from: workingHours, at: index) else { return nil }
        return String(format: "%02d:%02d", tuple.h, tuple.m)
    }
}

private extension VenueCore.VenueType {
    var detailLabel: String {
        switch self {
        case .club: return "Клуб"
        case .bar: return "Бар"
        case .lounge: return "Лаундж"
        case .event: return "Събитие"
        case .other: return "Друго"
        }
    }

    var vibeLabel: String {
        switch self {
        case .club: return "Висока енергия"
        case .bar: return "Вечерен ритъм"
        case .lounge: return "Спокоен премиум ритъм"
        case .event: return "Фокусирана вечер"
        case .other: return "Нощен сигнал"
        }
    }

    var rhythmFallback: String {
        switch self {
        case .club: return "Късна вълна"
        case .bar: return "Вечерен ритъм"
        case .lounge: return "Спокоен ритъм"
        case .event: return "Събитийна вечер"
        case .other: return "Нощен ритъм"
        }
    }

    var whyNowFallback: String {
        switch self {
        case .club:
            return "Клубен избор за вечер с повече енергия. Използвай го, когато търсиш ясен нощен пик."
        case .bar:
            return "Бар избор за по-гъвкаво начало на вечерта. " +
                "Подходящо е за среща, загряване или по-лек ритъм."
        case .lounge:
            return "Лаундж избор за по-спокойна вечер. Подходящо е, когато атмосферата е по-важна от шума."
        case .event:
            return "Събитие с конкретен фокус. Провери часа и реши дали пасва на плана за вечерта."
        case .other:
            return "Локален нощен сигнал. Полезно е, ако търсиш алтернатива извън стандартните категории."
        }
    }
}
