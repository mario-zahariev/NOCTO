import SwiftUI
import NOCTOCore

struct HomeView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager

    var body: some View {
        NavigationStack {
            ZStack {
                NoctoTheme.cityBackdrop
                    .ignoresSafeArea()

                NoctoVenueFeedView(
                    venues: venues,
                    favorites: favorites,
                    statusMessage: nil,
                    onRefresh: {}
                )
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
