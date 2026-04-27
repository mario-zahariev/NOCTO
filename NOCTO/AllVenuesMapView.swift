import SwiftUI
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
                    Annotation(venue.name, coordinate: venue.coordinate) {
                        VStack(spacing: 2) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(NoctoTheme.accent)
                            Text(venue.name)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .navigationTitle("Map")
        }
    }
}
