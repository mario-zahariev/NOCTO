import SwiftUI
import NOCTOCore
import MapKit

struct AllVenuesMapView: View {
    let venues: [Venue]

    @State private var selectedVenueID: Venue.ID?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219),
            span: MKCoordinateSpan(latitudeDelta: 0.14, longitudeDelta: 0.14)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition) {
                    ForEach(venues) { venue in
                        Annotation(venue.name, coordinate: venue.coordinate) {
                            Button {
                                selectedVenueID = venue.id
                                Haptics.tap()
                            } label: {
                                PulseMapNode(
                                    label: venue.name,
                                    badge: VenueSignalResolver.badge(for: venue),
                                    isSelected: selectedVenueID == venue.id
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                .colorScheme(.dark)
                .saturation(0.30)
                .contrast(0.92)
                .brightness(-0.16)
                .ignoresSafeArea()

                mapAtmosphere
            }
            .navigationTitle("Карта")
        }
    }

    private var mapAtmosphere: some View {
        ZStack {
            LinearGradient(
                colors: [
                    NoctoTheme.background.opacity(0.56),
                    Color(hex: "#07101F").opacity(0.34),
                    NoctoTheme.background.opacity(0.50)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    NoctoTheme.accent.opacity(0.12),
                    NoctoTheme.ultraviolet.opacity(0.055),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 40,
                endRadius: 390
            )

            RadialGradient(
                colors: [
                    NoctoTheme.ultraviolet.opacity(0.075),
                    .clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct PulseMapNode: View {
    let label: String
    let badge: NOCTOVenueBadge?
    let isSelected: Bool

    private var tint: Color {
        badge == .quietPick ? NoctoTheme.ultraviolet : NoctoTheme.accent
    }

    private var secondaryTint: Color {
        badge == .quietPick ? NoctoTheme.accent : NoctoTheme.ultraviolet
    }

    var body: some View {
        VStack(spacing: isSelected ? 5 : 0) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                tint.opacity(isSelected ? 0.30 : 0.16),
                                tint.opacity(isSelected ? 0.10 : 0.045),
                                .clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: isSelected ? 33 : 23
                        )
                    )
                    .frame(width: isSelected ? 66 : 46, height: isSelected ? 66 : 46)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                secondaryTint.opacity(isSelected ? 0.13 : 0.065),
                                .clear
                            ],
                            center: .topTrailing,
                            startRadius: 1,
                            endRadius: isSelected ? 27 : 18
                        )
                    )
                    .frame(width: isSelected ? 52 : 34, height: isSelected ? 52 : 34)
                    .offset(x: isSelected ? 5 : 3, y: isSelected ? -4 : -2)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.94 : 0.82),
                                tint.opacity(0.96),
                                secondaryTint.opacity(isSelected ? 0.50 : 0.34)
                            ],
                            center: .topLeading,
                            startRadius: 1,
                            endRadius: isSelected ? 13 : 8
                        )
                    )
                    .frame(width: isSelected ? 18 : 11, height: isSelected ? 18 : 11)

                Circle()
                    .fill(Color.white.opacity(isSelected ? 0.70 : 0.42))
                    .frame(width: isSelected ? 4 : 2.5, height: isSelected ? 4 : 2.5)
                    .offset(x: isSelected ? -2.5 : -1.6, y: isSelected ? -2.5 : -1.6)

                if isSelected {
                    Circle()
                        .trim(from: 0.12, to: 0.82)
                        .stroke(tint.opacity(0.42), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(-28))
                }
            }
            .frame(width: isSelected ? 68 : 48, height: isSelected ? 68 : 48)
            .shadow(color: tint.opacity(isSelected ? 0.20 : 0.10), radius: isSelected ? 8 : 4, x: 0, y: 2)

            if isSelected {
                Text(label)
                    .font(.caption2.weight(.black))
                    .foregroundStyle(NoctoTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .shadow(color: Color.black.opacity(0.78), radius: 4, x: 0, y: 2)
            }
        }
    }
}
