import SwiftUI
import NOCTOCore

struct AdminDashboardView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager
    let snapshot: OperationalSnapshot

    var body: some View {
        NavigationStack {
            List {
                Section("Преглед") {
                    statRow("Общо места", value: "\(venues.count)")
                    statRow("Любими", value: "\(favorites.favoriteIDs.count)")
                    statRow("Късни места", value: "\(snapshot.lateNightVenueCount)")
                    statRow("Пълнота на данните", value: "\(snapshot.dataCompletenessPercent)%")
                    statRow("Време за зареждане", value: "\(snapshot.loadLatencyMs) ms")
                }

                Section("Състояние") {
                    statRow("Валидация на данните", value: snapshot.decodeHealthLabel)
                    statRow("Резервен режим", value: snapshot.fallbackLabel)
                    statRow("Клас на зареждане", value: snapshot.latencyBandLabel)
                    statRow("Увереност на сигнала", value: snapshot.signalConfidenceLabel)
                    statRow("Водещ формат", value: snapshot.primaryVenueTypeLabel)
                }

                if let lastError = snapshot.lastErrorMessage {
                    Section("Последна грешка") {
                        Text(lastError)
                            .font(.footnote)
                            .foregroundStyle(NoctoTheme.textSecondary)
                    }
                }
            }
            .navigationTitle("Админ")
        }
    }

    private func statRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 16)
            Text(value)
                .foregroundStyle(NoctoTheme.textSecondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(minWidth: 82, alignment: .trailing)
        }
    }
}
