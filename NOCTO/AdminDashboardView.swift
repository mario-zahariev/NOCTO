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
                    statRow("Общо локации", value: "\(venues.count)")
                    statRow("Любими", value: "\(favorites.favoriteIDs.count)")
                    statRow("Късни места", value: "\(snapshot.lateNightVenueCount)")
                    statRow("Пълнота на dataset-а", value: "\(snapshot.dataCompletenessPercent)%")
                    statRow("Load latency", value: "\(snapshot.loadLatencyMs) ms")
                    statRow("Документация", value: "Активна")
                }

                Section("Състояние") {
                    statRow("Валидация на хранилище", value: snapshot.decodeHealthLabel)
                    statRow("Fallback обработка", value: snapshot.fallbackLabel)
                    statRow("Латентност на зареждане", value: snapshot.latencyBandLabel)
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
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(NoctoTheme.textSecondary)
        }
    }
}
