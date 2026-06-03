import SwiftUI
import NOCTOCore

struct HomeView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            ZStack {
                homeDepthBackdrop

                ScrollView {
                    LazyVStack(spacing: 14) {
                        NightIntelligenceHeader(venues: venues)
                            .padding(.horizontal, 16)

                        ForEach(venues) { venue in
                            NavigationLink {
                                VenueDetailView(venue: venue)
                            } label: {
                                VenueCard(
                                    venue: venue,
                                    isFavorite: favorites.isFavorite(venue.id),
                                    badge: VenueSignalResolver.badge(for: venue),
                                    onToggleFavorite: {
                                        favorites.toggle(venue.id)
                                        Haptics.tap()
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Начало")
        }
    }

    private var homeDepthBackdrop: some View {
        ZStack {
            RadialGradient(
                colors: [
                    NoctoTheme.accent.opacity(0.12),
                    NoctoTheme.accent.opacity(0.03),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 16,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    NoctoTheme.ultraviolet.opacity(0.14),
                    NoctoTheme.ultraviolet.opacity(0.04),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 520
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.025),
                    .clear,
                    Color.black.opacity(0.24)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct NightIntelligenceHeader: View {
    let venues: [Venue]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("НОЩЕН РАДАР")
                        .font(.caption2.weight(.black))
                        .tracking(1.7)
                        .foregroundStyle(NoctoTheme.accent)

                    Text("NOCTO")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(NoctoTheme.textPrimary)

                    Text("Къде диша София тази нощ")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(NoctoTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                radarGlyph
            }

            NoctoSignalWave()
                .frame(height: 30)
                .padding(.top, -2)

            VStack(alignment: .leading, spacing: 10) {
                Text("ТАЗИ ВЕЧЕР")
                    .font(.caption.weight(.black))
                    .tracking(1.6)
                    .foregroundStyle(NoctoTheme.textSecondary)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        signalPill(value: "\(venues.count)", label: "локални сигнала")
                        signalPill(value: bestAfterLabel, label: "силен старт")
                        signalPill(value: lateCoverageLabel, label: "късно покритие")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        signalPill(value: "\(venues.count)", label: "локални сигнала")
                        signalPill(value: bestAfterLabel, label: "силен старт")
                        signalPill(value: lateCoverageLabel, label: "късно покритие")
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .noctoSurface(.hero, cornerRadius: 24)
        .allowsHitTesting(false)
    }

    private var radarGlyph: some View {
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.86)
                .stroke(NoctoTheme.accent.opacity(0.78), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-30))
                .frame(width: 46, height: 46)

            Circle()
                .stroke(NoctoTheme.ultraviolet.opacity(0.30), lineWidth: 1)
                .frame(width: 28, height: 28)

            Circle()
                .fill(NoctoTheme.accent)
                .frame(width: 7, height: 7)
        }
        .frame(width: 54, height: 54)
    }

    private func signalPill(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(NoctoTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(NoctoTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .noctoSurface(.embeddedPocket, cornerRadius: 14)
    }

    private var bestAfterLabel: String {
        let openingHours = venues.compactMap { venue -> Int? in
            Venue.hourMinuteTuple(from: venue.workingHours, at: 0)?.h
        }

        guard let hour = openingHours.frequencyModal else { return "няма" }
        return "след \(String(format: "%02d", hour)):00"
    }

    private var lateCoverageLabel: String {
        let closingMinutes = venues.compactMap { venue -> Int? in
            guard
                let opening = Venue.hourMinuteTuple(from: venue.workingHours, at: 0),
                let closing = Venue.hourMinuteTuple(from: venue.workingHours, at: 1)
            else { return nil }

            let openingValue = opening.h * 60 + opening.m
            let closingValue = closing.h * 60 + closing.m
            return closingValue <= openingValue ? closingValue + 24 * 60 : closingValue
        }

        guard let latest = closingMinutes.max() else { return "няма" }
        let normalized = latest % (24 * 60)
        return "до \(String(format: "%02d:%02d", normalized / 60, normalized % 60))"
    }
}

private extension Array where Element == Int {
    var frequencyModal: Int? {
        let grouped = Dictionary(grouping: self, by: { $0 })
        return grouped.max { lhs, rhs in
            if lhs.value.count == rhs.value.count {
                return lhs.key > rhs.key
            }
            return lhs.value.count < rhs.value.count
        }?.key
    }
}
