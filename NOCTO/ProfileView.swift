import SwiftUI

struct ProfileView: View {
    let favoritesCount: Int
    let snapshot: OperationalSnapshot
    let venues: [Venue]
    let favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nightPassCard
                    tonightCard
                    statusCard

                    #if DEBUG
                    debugAdminLink
                    #endif
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Профил")
        }
    }

    private var nightPassCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NOCTO")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(NoctoTheme.textSecondary)

                    Text("Night Pass")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(NoctoTheme.textPrimary)

                    Text("Личният ти нощен профил")
                        .font(.subheadline)
                        .foregroundStyle(NoctoTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(NoctoTheme.accent)
                    .padding(10)
                    .background(Circle().fill(NoctoTheme.accent.opacity(0.16)))
            }

            HStack(spacing: 10) {
                profilePill("Локален", systemImage: "iphone")
                profilePill("Дискретен", systemImage: "lock")
                profilePill("Sofia", systemImage: "moon.stars")
            }
        }
        .profileCard()
    }

    private var tonightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Тази вечер")

            metricRow("Любими", value: "\(favoritesCount)", systemImage: "heart")
            metricRow("Пулс", value: snapshot.lateNightAvailabilityLabel, systemImage: "waveform.path.ecg")
            metricRow("Сигнал", value: snapshot.signalConfidenceLabel, systemImage: "dot.radiowaves.left.and.right")
        }
        .profileCard()
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Статус")

            metricRow("Данни", value: "\(snapshot.dataCompletenessPercent)%", systemImage: "checkmark.seal")
            metricRow("Източник", value: "Локален", systemImage: "internaldrive")
            metricRow("Фокус", value: snapshot.primaryVenueTypeLabel, systemImage: "sparkles")
        }
        .profileCard()
    }

    #if DEBUG
    private var debugAdminLink: some View {
        NavigationLink {
            AdminDashboardView(venues: venues, favorites: favorites, snapshot: snapshot)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "gauge.with.dots.needle.67percent")
                    .font(.headline)
                    .foregroundStyle(NoctoTheme.accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Админ")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(NoctoTheme.textPrimary)
                    Text("Само за разработка")
                        .font(.caption)
                        .foregroundStyle(NoctoTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NoctoTheme.textSecondary)
            }
            .profileCard()
        }
        .buttonStyle(.plain)
    }
    #endif

    private func profilePill(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(NoctoTheme.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(NoctoTheme.background.opacity(0.72)))
            .overlay(Capsule().stroke(NoctoTheme.cardBorder, lineWidth: 1))
    }

    private func metricRow(_ title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(NoctoTheme.accent)
                .frame(width: 22)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(NoctoTheme.textPrimary)

            Spacer(minLength: 16)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(NoctoTheme.textSecondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .foregroundStyle(NoctoTheme.textSecondary)
    }
}

private extension View {
    func profileCard() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(NoctoTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(NoctoTheme.cardBorder, lineWidth: 1)
            )
    }
}
