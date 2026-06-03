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
                    Annotation(venue.name, coordinate: venue.coordinate) {
                        DetailPulseMapNode()
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                .colorScheme(.dark)
                .saturation(0.34)
                .contrast(0.96)
                .brightness(-0.13)
                .frame(height: 260)
                .overlay(detailMapAtmosphere.allowsHitTesting(false))
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .shadow(color: NoctoTheme.accent.opacity(0.10), radius: 24, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.36), radius: 30, x: 0, y: 18)

                Text(venue.name)
                    .font(.largeTitle.bold())
                    .foregroundStyle(NoctoTheme.textPrimary)

                Text(venue.description)
                    .font(.body)
                    .foregroundStyle(NoctoTheme.textSecondary)

                VenueDetailSignalRow(kind: .node, text: venue.address)

                VenueDetailSignalRow(kind: .time, text: venue.workingHours)
            }
            .padding(20)
        }
        .background(NoctoTheme.background.ignoresSafeArea())
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var detailMapAtmosphere: some View {
        ZStack {
            LinearGradient(
                colors: [
                    NoctoTheme.background.opacity(0.50),
                    .clear,
                    NoctoTheme.background.opacity(0.42)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    NoctoTheme.accent.opacity(0.13),
                    NoctoTheme.ultraviolet.opacity(0.055),
                    .clear
                ],
                center: .center,
                startRadius: 28,
                endRadius: 210
            )
        }
    }
}

private struct DetailPulseMapNode: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            NoctoTheme.accent.opacity(0.34),
                            NoctoTheme.accent.opacity(0.09),
                            .clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: 44
                    )
                )
                .frame(width: 88, height: 88)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            NoctoTheme.ultraviolet.opacity(0.16),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 1,
                        endRadius: 34
                    )
                )
                .frame(width: 66, height: 66)
                .offset(x: 7, y: -5)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.94),
                            NoctoTheme.accent.opacity(0.98),
                            NoctoTheme.ultraviolet.opacity(0.56)
                        ],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: 17
                    )
                )
                .frame(width: 24, height: 24)

            Circle()
                .fill(Color.white.opacity(0.74))
                .frame(width: 5, height: 5)
                .offset(x: -3, y: -3)

            Circle()
                .trim(from: 0.10, to: 0.82)
                .stroke(NoctoTheme.accent.opacity(0.42), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
                .frame(width: 42, height: 42)
                .rotationEffect(.degrees(-30))
        }
        .frame(width: 92, height: 92)
        .shadow(color: NoctoTheme.accent.opacity(0.20), radius: 10, x: 0, y: 3)
    }
}

private struct VenueDetailSignalRow: View {
    enum Kind {
        case node
        case time
    }

    let kind: Kind
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 9) {
            DetailSignalGlyph(kind: kind)
                .frame(width: 18, height: 18)

            Text(text)
                .font(.body)
                .foregroundStyle(NoctoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct DetailSignalGlyph: View {
    let kind: VenueDetailSignalRow.Kind

    var body: some View {
        ZStack {
            switch kind {
            case .node:
                Circle()
                    .stroke(NoctoTheme.accent.opacity(0.86), lineWidth: 2)
                    .frame(width: 15, height: 15)

                Circle()
                    .fill(NoctoTheme.accent)
                    .frame(width: 4, height: 4)

            case .time:
                Circle()
                    .trim(from: 0.12, to: 0.88)
                    .stroke(NoctoTheme.ultraviolet.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-45))
                    .frame(width: 16, height: 16)

                Circle()
                    .fill(NoctoTheme.ultraviolet)
                    .frame(width: 4, height: 4)
            }
        }
    }
}
