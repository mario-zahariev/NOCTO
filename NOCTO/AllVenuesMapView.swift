import SwiftUI
import NOCTOCore
import MapKit

struct AllVenuesMapView: View {
    let venues: [Venue]

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219),
            span: MKCoordinateSpan(latitudeDelta: 0.14, longitudeDelta: 0.14)
        )
    )

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(venues) { venue in
                    Marker(venue.name, coordinate: venue.coordinate)
                        .tint(NoctoTheme.accent)
                }
            }
            .navigationTitle("Карта")
        }
    }
}
