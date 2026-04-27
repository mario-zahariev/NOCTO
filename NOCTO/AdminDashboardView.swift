import SwiftUI
import NOCTOCore

struct AdminDashboardView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    statRow("Общо venues", value: "\(venues.count)")
                    statRow("Favorites", value: "\(favorites.favoriteIDs.count)")
                    statRow("Документация", value: "Enabled")
                }

                Section("Health") {
                    statRow("Repository validation", value: "Active")
                    statRow("Fallback handling", value: "Active")
                    statRow("Error boundaries", value: "Basic")
                }
            }
            .navigationTitle("Admin")
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
