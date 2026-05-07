import SwiftUI

struct NightPulseView: View {
    let snapshot: OperationalSnapshot

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    signalCard
                    typeMixCard
                    qualityCard
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Пулс")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Пулсът тази вечер")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(NoctoTheme.textPrimary)
                    Text("\(snapshot.venuesCount) места · \(snapshot.lateNightVenueCount) късни · \(snapshot.primaryVenueTypeLabel)")
                        .font(.caption)
                        .foregroundStyle(NoctoTheme.textSecondary)
                }
                Spacer()
                scoreBadge("\(snapshot.trafficIndex)")
            }

            pulseProgressBar(value: snapshot.trafficIndex, total: 100, tint: NoctoTheme.accent)
                .frame(height: 5)

            HStack(spacing: 12) {
                compactMetric("Наличност", value: snapshot.lateNightAvailabilityLabel)
                Rectangle()
                    .fill(NoctoTheme.cardBorder)
                    .frame(width: 1)
                compactMetric("Увереност", value: snapshot.signalConfidenceLabel)
                Rectangle()
                    .fill(NoctoTheme.cardBorder)
                    .frame(width: 1)
                compactMetric("Данни", value: "\(snapshot.dataCompletenessPercent)%")
            }
        }
        .nightPulseCard()
    }

    private var signalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Сигнали")
            confidenceStrip
            signalRow("Основен формат", value: snapshot.primaryVenueTypeLabel, systemImage: "music.note.house")
            signalRow("Късно покритие", value: "\(snapshot.lateNightVenueCount) места · \(snapshot.lateNightCoverageHours) ч", systemImage: "moon.stars")
            signalRow("Най-добре след", value: snapshot.bestAfterTime, systemImage: "clock.badge")
            signalRow("Зареждане", value: "\(snapshot.loadLatencyMs) ms · \(snapshot.latencyBandLabel)", systemImage: "speedometer")
            signalRow("Валидация", value: snapshot.confidenceValidationLabel, systemImage: "checkmark.seal")
            signalRow("Източник", value: snapshot.confidenceSource.label, systemImage: "internaldrive")
        }
        .nightPulseCard()
    }

    private var typeMixCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Микс от места")
            if snapshot.typeSignals.isEmpty {
                Text("Няма валиден типаж за показване")
                    .font(.subheadline)
                    .foregroundStyle(NoctoTheme.textSecondary)
            } else {
                ForEach(snapshot.typeSignals) { signal in
                    typeMixRow(signal)
                }
            }
        }
        .nightPulseCard()
    }

    private var qualityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Оперативно качество")
            signalRow("Пълнота на данните", value: "\(snapshot.dataCompletenessPercent)%", systemImage: "chart.bar.doc.horizontal")
            signalRow("Резервен режим", value: snapshot.fallbackLabel, systemImage: "arrow.triangle.2.circlepath")
            signalRow("Източник", value: "Локален venues.json", systemImage: "internaldrive")
        }
        .nightPulseCard()
    }

    private func compactMetric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(NoctoTheme.textSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(NoctoTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var confidenceStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Сигнал над шум")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NoctoTheme.textSecondary)
                Spacer()
                Text("\(snapshot.confidenceScore)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NoctoTheme.ultraviolet)
            }

            pulseProgressBar(value: snapshot.confidenceScore, total: 100, tint: NoctoTheme.ultraviolet)
            .frame(height: 4)
        }
    }

    private func signalRow(_ title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(NoctoTheme.accent)
                .frame(width: 22)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(NoctoTheme.textPrimary)

            Spacer()

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(NoctoTheme.textSecondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func typeMixRow(_ signal: VenueTypeSignal) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(signal.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(NoctoTheme.textPrimary)
                Spacer()
                Text("\(signal.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NoctoTheme.textSecondary)
            }

            pulseProgressBar(value: signal.count, total: max(snapshot.venuesCount, 1), tint: NoctoTheme.accent)
                .frame(height: 4)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .foregroundStyle(NoctoTheme.textSecondary)
    }

    private func scoreBadge(_ text: String) -> some View {
        Text(text)
            .font(.title2.weight(.bold))
            .foregroundStyle(NoctoTheme.textPrimary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Capsule().fill(NoctoTheme.accent.opacity(0.22)))
            .overlay(Capsule().stroke(NoctoTheme.accent.opacity(0.7), lineWidth: 1))
    }

    private func pulseProgressBar(value: Int, total: Int, tint: Color) -> some View {
        let safeTotal = max(total, 1)
        let safeValue = min(max(value, 0), safeTotal)
        let ratio = Double(safeValue) / Double(safeTotal)

        return Capsule()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: tint, location: 0),
                        .init(color: tint, location: ratio),
                        .init(color: NoctoTheme.cardBorder.opacity(0.65), location: ratio),
                        .init(color: NoctoTheme.cardBorder.opacity(0.65), location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

private extension View {
    func nightPulseCard() -> some View {
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
