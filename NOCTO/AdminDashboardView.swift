import SwiftUI
import NOCTOCore

struct AdminDashboardView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            List {
                Section("Преглед") {
                    statRow("Общо локации", value: "\(venues.count)")
                    statRow("Любими", value: "\(favorites.favoriteIDs.count)")
                    statRow("Документация", value: "Активна")
                }

                // TODO: Wire these health statuses to a real health provider before production.
                Section("Състояние") {
                    statRow("Валидация на хранилище", value: "Плейсхолдър")
                    statRow("Fallback обработка", value: "Плейсхолдър")
                    statRow("Граници на грешки", value: "Плейсхолдър")
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
