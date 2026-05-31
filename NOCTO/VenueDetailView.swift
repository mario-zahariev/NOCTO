import SwiftUI
import NOCTOCore
import MapKit

struct VenueDetailView: View {
    let venue: Venue

    @State private var cameraPosition: MapCameraPosition

    init(venue: Venue) {
        self.venue = venue
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
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Map(position: $cameraPosition) {
                    Marker(venue.name, coordinate: venue.coordinate)
                        .tint(NoctoTheme.accent)
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(venue.name)
                    .font(.largeTitle.bold())
                    .foregroundStyle(NoctoTheme.textPrimary)

                Text(venue.description)
                    .font(.body)
                    .foregroundStyle(NoctoTheme.textSecondary)

                Label(venue.address, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(NoctoTheme.textSecondary)

                Label(venue.workingHours, systemImage: "clock")
                    .foregroundStyle(NoctoTheme.textSecondary)
            }
            .padding(20)
        }
        .background(NoctoTheme.background.ignoresSafeArea())
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
