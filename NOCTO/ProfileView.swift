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

                ProfileGlyph(kind: .aura, tint: NoctoTheme.accent)
                    .frame(width: 46, height: 46)
                    .padding(10)
                    .background(Circle().fill(NoctoTheme.accent.opacity(0.16)))
            }

            HStack(spacing: 10) {
                profilePill("Локален", kind: .device)
                profilePill("Дискретен", kind: .lock)
                profilePill("Sofia", kind: .moon)
            }
        }
        .profileCard()
    }

    private var tonightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Тази вечер")

            metricRow("Любими", value: "\(favoritesCount)", kind: .spark)
            metricRow("Пулс", value: snapshot.lateNightAvailabilityLabel, kind: .resonance)
            metricRow("Сигнал", value: snapshot.signalConfidenceLabel, kind: .signal)
        }
        .profileCard()
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Статус")

            metricRow("Данни", value: "\(snapshot.dataCompletenessPercent)%", kind: .seal)
            metricRow("Източник", value: "Локален", kind: .source)
            metricRow("Фокус", value: snapshot.primaryVenueTypeLabel, kind: .focus)
        }
        .profileCard()
    }

    #if DEBUG
    private var debugAdminLink: some View {
        NavigationLink {
            AdminDashboardView(venues: venues, favorites: favorites, snapshot: snapshot)
        } label: {
            HStack(spacing: 12) {
                ProfileGlyph(kind: .signal, tint: NoctoTheme.accent)
                    .frame(width: 24, height: 24)

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

    private func profilePill(_ title: String, kind: ProfileGlyph.Kind) -> some View {
        HStack(spacing: 7) {
            ProfileGlyph(kind: kind, tint: NoctoTheme.textPrimary)
                .frame(width: 17, height: 17)

            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .foregroundStyle(NoctoTheme.textPrimary)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .noctoSurface(.embeddedPocket, cornerRadius: 18)
    }

    private func metricRow(_ title: String, value: String, kind: ProfileGlyph.Kind) -> some View {
        HStack(spacing: 10) {
            ProfileGlyph(kind: kind, tint: NoctoTheme.accent)
                .frame(width: 22, height: 22)

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

private struct ProfileGlyph: View {
    enum Kind {
        case aura
        case spark
        case resonance
        case signal
        case seal
        case source
        case focus
        case device
        case lock
        case moon
    }

    let kind: Kind
    let tint: Color

    var body: some View {
        ZStack {
            switch kind {
            case .aura:
                Circle()
                    .stroke(tint, lineWidth: 3)
                Circle()
                    .fill(tint)
                    .frame(width: 12, height: 12)
                    .offset(x: 6, y: -5)
                Circle()
                    .stroke(tint.opacity(0.45), lineWidth: 2)
                    .frame(width: 22, height: 22)

            case .spark, .focus:
                Text("✦")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(tint)

            case .resonance:
                HStack(alignment: .center, spacing: 3) {
                    ForEach([8.0, 15.0, 22.0, 12.0], id: \.self) { height in
                        Capsule()
                            .fill(tint)
                            .frame(width: 3, height: height)
                    }
                }

            case .signal:
                ForEach([12.0, 18.0, 24.0], id: \.self) { size in
                    Circle()
                        .stroke(tint.opacity(size == 24 ? 0.28 : 0.62), lineWidth: 2)
                        .frame(width: size, height: size)
                }
                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)

            case .seal:
                Circle()
                    .stroke(tint, lineWidth: 2.4)
                Text("✓")
                    .font(.caption.weight(.black))
                    .foregroundStyle(tint)

            case .source:
                RoundedRectangle(cornerRadius: 4)
                    .stroke(tint, lineWidth: 2)
                    .frame(width: 20, height: 14)
                Capsule()
                    .fill(tint.opacity(0.76))
                    .frame(width: 12, height: 3)
                    .offset(y: 4)

            case .device:
                RoundedRectangle(cornerRadius: 4)
                    .stroke(tint, lineWidth: 2)
                    .frame(width: 13, height: 21)
                Circle()
                    .fill(tint)
                    .frame(width: 3, height: 3)
                    .offset(y: 7)

            case .lock:
                RoundedRectangle(cornerRadius: 4)
                    .stroke(tint, lineWidth: 2)
                    .frame(width: 18, height: 13)
                    .offset(y: 4)
                Circle()
                    .trim(from: 0.55, to: 0.95)
                    .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 14, height: 14)
                    .offset(y: -3)

            case .moon:
                Circle()
                    .fill(tint)
                Circle()
                    .fill(NoctoTheme.surfaceRaised)
                    .frame(width: 18, height: 18)
                    .offset(x: 6, y: -4)
            }
        }
    }
}

private extension View {
    func profileCard() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .noctoSurface(.raised, cornerRadius: 14)
    }
}
