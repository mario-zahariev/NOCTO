import SwiftUI
import NOCTOCore
import MapKit

struct AllVenuesMapView: View {
    let venues: [Venue]

    @State private var cameraPosition: MapCameraPosition = .region(Self.defaultRegion)
    @State private var selectedVenueID: Venue.ID?

    private static let userCoordinate = CLLocationCoordinate2D(latitude: 42.6973, longitude: 23.3241)

    private static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219),
        span: MKCoordinateSpan(latitudeDelta: 0.055, longitudeDelta: 0.055)
    )

    private var displayVenues: [Venue] {
        venues.isEmpty ? [VisualFallbackVenue.make()] : venues
    }

    private var selectedVenue: Venue? {
        guard let selectedVenueID else { return nil }
        return displayVenues.first { $0.id == selectedVenueID }
    }

    private var focusedVenue: Venue? {
        selectedVenue
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let scale = NoctoHTML.scale(for: proxy.size)

                ZStack(alignment: .top) {
                    Map(position: $cameraPosition, interactionModes: .all) {
                        if let focusedVenue {
                            let route = routeCoordinates(to: focusedVenue)

                            MapPolyline(coordinates: route)
                                .stroke(NoctoTheme.signalAfter.opacity(0.18), lineWidth: 18)

                            MapPolyline(coordinates: route)
                                .stroke(NoctoTheme.signalAfter.opacity(0.30), lineWidth: 9)

                            MapPolyline(coordinates: route)
                                .stroke(NoctoTheme.signalAfter.opacity(0.86), lineWidth: 4)
                        }

                        Annotation("", coordinate: Self.userCoordinate, anchor: .center) {
                            NoctoUserMapDot(scale: scale)
                                .accessibilityLabel("Твоята позиция")
                        }

                        ForEach(displayVenues) { venue in
                            Annotation("", coordinate: venue.coordinate, anchor: .center) {
                                Button {
                                    select(venue)
                                } label: {
                                    NoctoInteractiveMapPin(
                                        venue: venue,
                                        isSelected: selectedVenue?.id == venue.id,
                                        scale: scale
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                    .colorScheme(.dark)
                    .saturation(0.46)
                    .contrast(0.96)
                    .brightness(-0.12)
                    .ignoresSafeArea()

                    NoctoMapAtmosphereOverlay(scale: scale)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    NoctoHTMLStatusBar(scale: scale, compactSignal: true)
                        .allowsHitTesting(false)

                    if let focusedVenue {
                        NoctoSelectedRouteHUD(
                            venue: focusedVenue,
                            scale: scale,
                            routeDistanceMeters: routeDistanceMeters(to: focusedVenue)
                        )
                        .padding(.top, 78 * scale)
                        .padding(.leading, 14 * scale)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .allowsHitTesting(false)

                        NoctoRouteArrowGlyph()
                            .fill(NoctoTheme.signalAfter)
                            .frame(width: 22 * scale, height: 26 * scale)
                            .shadow(color: NoctoTheme.signalAfter.opacity(0.70), radius: 10 * scale)
                            .rotationEffect(.degrees(28))
                            .position(x: proxy.size.width * 0.76, y: proxy.size.height * 0.36)
                            .allowsHitTesting(false)
                    }

                    NoctoMapControls(
                        scale: scale,
                        onZoomIn: { zoom(by: 0.55) },
                        onZoomOut: { zoom(by: 1.75) },
                        onReset: resetCamera
                    )
                    .padding(.top, 112 * scale)
                    .padding(.trailing, 12 * scale)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    VStack {
                        Spacer()

                        NoctoHTMLMapSheet(
                            venues: displayVenues,
                            selectedVenue: selectedVenue,
                            scale: scale,
                            onSelect: select
                        )
                            .padding(.horizontal, 11 * scale)
                            .padding(.bottom, 58 * scale)
                    }
                }
                .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func select(_ venue: Venue) {
        selectedVenueID = venue.id
        Haptics.tap()

        let currentSpan = cameraPosition.region?.span ?? Self.defaultRegion.span
        let focusedSpan = MKCoordinateSpan(
            latitudeDelta: min(currentSpan.latitudeDelta, 0.030),
            longitudeDelta: min(currentSpan.longitudeDelta, 0.030)
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: venue.coordinate,
                    span: focusedSpan
                )
            )
        }
    }

    private func zoom(by factor: CLLocationDegrees) {
        let region = cameraPosition.region ?? Self.defaultRegion
        let nextSpan = MKCoordinateSpan(
            latitudeDelta: min(max(region.span.latitudeDelta * factor, 0.004), 0.16),
            longitudeDelta: min(max(region.span.longitudeDelta * factor, 0.004), 0.16)
        )

        withAnimation(.easeInOut(duration: 0.20)) {
            cameraPosition = .region(MKCoordinateRegion(center: region.center, span: nextSpan))
        }
    }

    private func resetCamera() {
        selectedVenueID = nil
        Haptics.tap()

        withAnimation(.easeInOut(duration: 0.25)) {
            cameraPosition = .region(Self.defaultRegion)
        }
    }

    private func routeCoordinates(to venue: Venue) -> [CLLocationCoordinate2D] {
        let start = Self.userCoordinate
        let end = venue.coordinate
        let bend = CLLocationCoordinate2D(
            latitude: (start.latitude + end.latitude) / 2 + 0.0024,
            longitude: (start.longitude + end.longitude) / 2 - 0.0028
        )

        return [start, bend, end]
    }

    private func routeDistanceMeters(to venue: Venue) -> CLLocationDistance {
        CLLocation(latitude: Self.userCoordinate.latitude, longitude: Self.userCoordinate.longitude)
            .distance(from: CLLocation(latitude: venue.latitude, longitude: venue.longitude))
    }
}

private struct NoctoMapAtmosphereOverlay: View {
    let scale: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        NoctoTheme.background.opacity(0.58),
                        Color(hex: "#10070C").opacity(0.34),
                        NoctoTheme.background.opacity(0.46)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [
                        NoctoTheme.accent.opacity(0.10),
                        NoctoTheme.accent.opacity(0.025),
                        .clear
                    ],
                    center: .init(x: 0.38, y: 0.44),
                    startRadius: 0,
                    endRadius: 280 * scale
                )

                RadialGradient(
                    colors: [
                        NoctoTheme.signalAfter.opacity(0.055),
                        .clear
                    ],
                    center: .init(x: 0.74, y: 0.62),
                    startRadius: 0,
                    endRadius: 220 * scale
                )

                NoctoHTMLMapGrid()
                    .stroke(NoctoTheme.accent.opacity(0.028), lineWidth: 1)

                NoctoMapStreet(y: 0.32, rotation: -2, opacity: 0.70, scale: scale)
                NoctoMapStreet(y: 0.56, rotation: 1, opacity: 0.70, scale: scale)
                NoctoMapStreet(y: 0.20, rotation: 3, opacity: 0.38, scale: scale)
                NoctoMapStreetVertical(x: 0.34, rotation: 1.5, opacity: 0.65, scale: scale)
                NoctoMapStreetVertical(x: 0.66, rotation: -1, opacity: 0.65, scale: scale)
                NoctoMapStreetVertical(x: 0.50, rotation: 0.8, opacity: 0.34, scale: scale)

                NoctoMapGlowZone(color: NoctoTheme.accent, opacity: 0.09)
                    .frame(width: 110 * scale, height: 110 * scale)
                    .position(x: proxy.size.width * 0.40, y: proxy.size.height * 0.43)

                NoctoMapGlowZone(color: NoctoTheme.event, opacity: 0.07)
                    .frame(width: 80 * scale, height: 80 * scale)
                    .position(x: proxy.size.width * 0.24, y: proxy.size.height * 0.30)
            }
        }
    }
}

private struct NoctoHTMLMapGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 26

        var x = rect.minX
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += spacing
        }

        var y = rect.minY
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }

        return path
    }
}

private struct NoctoMapStreet: View {
    let y: CGFloat
    let rotation: Double
    let opacity: Double
    let scale: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(NoctoTheme.accent.opacity(0.055 * opacity))
                .frame(width: proxy.size.width, height: 2 * scale)
                .rotationEffect(.degrees(rotation))
                .position(x: proxy.size.width / 2, y: proxy.size.height * y)
        }
        .allowsHitTesting(false)
    }
}

private struct NoctoMapStreetVertical: View {
    let x: CGFloat
    let rotation: Double
    let opacity: Double
    let scale: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(NoctoTheme.accent.opacity(0.055 * opacity))
                .frame(width: 2 * scale, height: proxy.size.height)
                .rotationEffect(.degrees(rotation))
                .position(x: proxy.size.width * x, y: proxy.size.height / 2)
        }
        .allowsHitTesting(false)
    }
}

private struct NoctoMapGlowZone: View {
    let color: Color
    let opacity: Double

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(opacity),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 70
                )
            )
    }
}

private struct NoctoInteractiveMapPin: View {
    let venue: Venue
    let isSelected: Bool
    let scale: CGFloat

    var body: some View {
        NoctoHTMLMapDot(
            title: isSelected ? venue.mapPinTitle : nil,
            tint: venue.mapPinTint,
            size: venue.mapPinSize(isSelected: isSelected) * scale,
            ringInset: venue.mapPinRingInset(isSelected: isSelected) * scale,
            rings: venue.mapPinRings(isSelected: isSelected),
            labelColor: venue.mapPinLabelColor,
            signal: venue.mapPinSignal,
            scale: scale
        )
        .scaleEffect(isSelected ? 1.08 : 1)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
        .contentShape(Circle())
        .accessibilityLabel("\(venue.name), \(venue.mapBadgeText)")
    }
}

private struct NoctoMapControls: View {
    let scale: CGFloat
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 6 * scale) {
            control("+", action: onZoomIn)
            control("−", action: onZoomOut)
            control("•", action: onReset)
        }
        .padding(5 * scale)
        .background(
            RoundedRectangle(cornerRadius: 12 * scale)
                .fill(Color(hex: "#03020C").opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12 * scale)
                .stroke(NoctoTheme.Colors.borderSoft.opacity(0.32), lineWidth: 1)
        )
    }

    private func control(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15 * scale, weight: .bold))
                .foregroundStyle(NoctoTheme.textPrimary)
                .frame(width: 28 * scale, height: 28 * scale)
                .background(
                    Circle()
                        .fill(NoctoTheme.Colors.surfaceElevated.opacity(0.82))
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

private struct NoctoSelectedRouteHUD: View {
    let venue: Venue
    let scale: CGFloat
    let routeDistanceMeters: CLLocationDistance

    private var etaMinutes: Int {
        max(4, Int(ceil(routeDistanceMeters / 78)))
    }

    private var distanceLabel: String {
        if routeDistanceMeters >= 1000 {
            return String(format: "%.1f km", routeDistanceMeters / 1000)
        }

        return "\(Int(routeDistanceMeters.rounded())) m"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10 * scale) {
            NoctoRouteRail(scale: scale, tint: NoctoTheme.signalAfter)
                .frame(width: 28 * scale, height: 154 * scale)

            VStack(alignment: .leading, spacing: 12 * scale) {
                VStack(alignment: .leading, spacing: 3 * scale) {
                    Text("DESTINATION")
                        .font(.system(size: 6 * scale, weight: .bold))
                        .tracking(2 * scale)
                        .foregroundStyle(NoctoTheme.textTertiary)

                    Text(venue.name)
                        .font(.system(size: 13 * scale, weight: .semibold))
                        .foregroundStyle(NoctoTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }

                HStack(alignment: .center, spacing: 8 * scale) {
                    NoctoTurnGlyph(scale: scale)
                        .stroke(NoctoTheme.textPrimary, style: StrokeStyle(lineWidth: 2 * scale, lineCap: .round, lineJoin: .round))
                        .frame(width: 25 * scale, height: 18 * scale)

                    VStack(alignment: .leading, spacing: 2 * scale) {
                        Text("Фокус след \(distanceLabel)")
                            .font(.system(size: 11 * scale, weight: .semibold))
                            .foregroundStyle(NoctoTheme.textPrimary)
                            .lineLimit(1)

                        Text(venue.address.isEmpty ? venue.mapSheetMeta : venue.address)
                            .font(.system(size: 7 * scale, weight: .medium))
                            .foregroundStyle(NoctoTheme.textSecondary.opacity(0.78))
                            .lineLimit(1)
                    }
                }

                HStack(spacing: 7 * scale) {
                    Circle()
                        .fill(NoctoTheme.textPrimary)
                        .frame(width: 8 * scale, height: 8 * scale)
                        .shadow(color: NoctoTheme.textPrimary.opacity(0.35), radius: 4 * scale)

                    Text("\(venue.noctoState.pulseScore)% pulse")
                        .font(.system(size: 10 * scale, weight: .semibold))
                        .foregroundStyle(NoctoTheme.textPrimary)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("\(etaMinutes)")
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundStyle(NoctoTheme.textPrimary)

                    Text("minutes")
                        .font(.system(size: 8 * scale, weight: .medium))
                        .foregroundStyle(NoctoTheme.textSecondary.opacity(0.82))
                }
                .padding(.top, 4 * scale)
            }
            .frame(width: 140 * scale, alignment: .leading)
        }
        .padding(.horizontal, 10 * scale)
        .padding(.vertical, 12 * scale)
        .background(
            RoundedRectangle(cornerRadius: 18 * scale)
                .fill(Color.black.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18 * scale)
                .stroke(Color.white.opacity(0.035), lineWidth: 1)
        )
    }
}

private struct NoctoRouteRail: View {
    let scale: CGFloat
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let x = proxy.size.width / 2
            let nodes: [(CGFloat, Double)] = [(0.05, 1.0), (0.35, 1.0), (0.58, 0.82), (0.77, 0.40), (0.95, 0.32)]

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: x, y: proxy.size.height * 0.05))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height * 0.95))
                }
                .stroke(
                    Color.white.opacity(0.28),
                    style: StrokeStyle(lineWidth: 1.5 * scale, lineCap: .round, dash: [6 * scale, 7 * scale])
                )

                ForEach(Array(nodes.enumerated()), id: \.offset) { index, node in
                    let y = proxy.size.height * node.0
                    let opacity = node.1

                    Circle()
                        .stroke(Color.white.opacity(0.18 * opacity), lineWidth: 6 * scale)
                        .frame(width: 18 * scale, height: 18 * scale)
                        .position(x: x, y: y)

                    Circle()
                        .fill(index < 2 ? Color.white : tint.opacity(0.34))
                        .frame(width: (index == 2 ? 8 : 12) * scale, height: (index == 2 ? 8 : 12) * scale)
                        .shadow(color: (index < 2 ? Color.white : tint).opacity(0.30 * opacity), radius: 8 * scale)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

private struct NoctoTurnGlyph: Shape {
    let scale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY

        path.move(to: CGPoint(x: rect.maxX, y: midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.35, y: midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY + rect.height * 0.30),
            control: CGPoint(x: rect.minX + rect.width * 0.24, y: midY)
        )
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.35, y: midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.54, y: rect.minY + rect.height * 0.26))
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.35, y: midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.54, y: rect.maxY - rect.height * 0.26))

        return path
    }
}

private struct NoctoRouteArrowGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.72))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct NoctoHTMLMapDot: View {
    let title: String?
    let tint: Color
    let size: CGFloat
    let ringInset: CGFloat
    let rings: Int
    let labelColor: Color
    let signal: NoctoMapPinSignal
    let scale: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            tint.opacity(signal.outerHaloOpacity),
                            tint.opacity(signal.outerHaloOpacity * 0.30),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: signal.outerHaloEndRadius * scale
                    )
                )
                .frame(width: size * signal.outerHaloScale, height: size * signal.outerHaloScale)
                .blur(radius: signal.outerHaloBlur * scale)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            tint.opacity(signal.innerHaloOpacity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: signal.innerHaloEndRadius * scale
                    )
                )
                .frame(width: size * 2.2, height: size * 2.2)

            ForEach(0..<rings, id: \.self) { index in
                Circle()
                    .stroke(tint.opacity(signal.ringOpacity(index: index)), lineWidth: 1)
                    .frame(width: size + ringInset * 2 + CGFloat(index) * 5 * scale)
                    .opacity(signal.ringLayerOpacity)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(signal.coreHighlightOpacity),
                            tint.opacity(signal.coreOpacity),
                            tint.opacity(signal.coreFloorOpacity)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(signal.coreBorderOpacity), lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .stroke(tint.opacity(signal.coreSignalBorderOpacity), lineWidth: 1.5 * scale)
                        .frame(width: size + 4 * scale, height: size + 4 * scale)
                )

            if signal == .event {
                Circle()
                    .fill(NoctoTheme.gold)
                    .frame(width: 4 * scale, height: 4 * scale)
                    .offset(x: size * 0.42, y: -size * 0.42)
                    .shadow(color: NoctoTheme.gold.opacity(0.35), radius: 3 * scale)
            }

            if let title {
                Text(title)
                    .font(.system(size: 7 * scale, weight: .bold))
                    .tracking(1 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(labelColor)
                    .lineLimit(1)
                    .padding(.horizontal, 7 * scale)
                    .padding(.vertical, 2 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 5 * scale)
                            .fill(Color(hex: "#06030E").opacity(signal.labelBackgroundOpacity))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5 * scale)
                            .stroke(tint.opacity(signal.labelBorderOpacity), lineWidth: 1)
                    )
                    .shadow(color: tint.opacity(signal.labelShadowOpacity), radius: 6 * scale, x: 0, y: 2 * scale)
                    .offset(y: -26 * scale)
            }
        }
    }
}

private enum NoctoMapPinSignal: Equatable {
    case hot
    case event
    case steady
    case afterhours
    case minor

    var isPrimary: Bool {
        switch self {
        case .hot, .event: return true
        case .steady, .afterhours, .minor: return false
        }
    }

    var outerHaloOpacity: Double {
        switch self {
        case .hot: return 0.20
        case .event: return 0.16
        case .steady: return 0.10
        case .afterhours: return 0.14
        case .minor: return 0.08
        }
    }

    var outerHaloScale: CGFloat {
        switch self {
        case .hot: return 6.2
        case .event: return 5.8
        case .steady: return 4.6
        case .afterhours: return 4.8
        case .minor: return 3.7
        }
    }

    var outerHaloEndRadius: CGFloat {
        switch self {
        case .hot: return 58
        case .event: return 54
        case .steady: return 42
        case .afterhours: return 44
        case .minor: return 34
        }
    }

    var outerHaloBlur: CGFloat {
        switch self {
        case .hot: return 3.0
        case .event: return 2.6
        case .steady: return 1.6
        case .afterhours: return 2.0
        case .minor: return 1.2
        }
    }

    var innerHaloOpacity: Double {
        switch self {
        case .hot: return 0.24
        case .event: return 0.20
        case .steady: return 0.13
        case .afterhours: return 0.16
        case .minor: return 0.08
        }
    }

    var innerHaloEndRadius: CGFloat {
        switch self {
        case .hot, .event: return 22
        case .steady, .afterhours: return 18
        case .minor: return 14
        }
    }

    var ringLayerOpacity: Double {
        switch self {
        case .hot: return 0.34
        case .event: return 0.30
        case .steady: return 0.22
        case .afterhours: return 0.24
        case .minor: return 0.16
        }
    }

    func ringOpacity(index: Int) -> Double {
        let base: Double
        switch self {
        case .hot: base = 0.36
        case .event: base = 0.30
        case .steady: base = 0.18
        case .afterhours: base = 0.22
        case .minor: base = 0.12
        }

        return max(0.06, base - Double(index) * 0.08)
    }

    var coreHighlightOpacity: Double {
        switch self {
        case .hot, .event: return 0.72
        case .steady: return 0.50
        case .afterhours: return 0.58
        case .minor: return 0.32
        }
    }

    var coreOpacity: Double {
        switch self {
        case .hot: return 0.98
        case .event: return 0.94
        case .steady: return 0.84
        case .afterhours: return 0.88
        case .minor: return 0.72
        }
    }

    var coreFloorOpacity: Double {
        switch self {
        case .hot, .event: return 0.70
        case .steady: return 0.48
        case .afterhours: return 0.56
        case .minor: return 0.34
        }
    }

    var coreBorderOpacity: Double {
        switch self {
        case .hot, .event: return 0.28
        case .steady, .afterhours: return 0.18
        case .minor: return 0.10
        }
    }

    var coreSignalBorderOpacity: Double {
        switch self {
        case .hot: return 0.28
        case .event: return 0.24
        case .steady: return 0.13
        case .afterhours: return 0.18
        case .minor: return 0.10
        }
    }

    var labelBackgroundOpacity: Double {
        switch self {
        case .hot, .event: return 0.82
        case .steady, .afterhours: return 0.74
        case .minor: return 0.68
        }
    }

    var labelBorderOpacity: Double {
        switch self {
        case .hot: return 0.22
        case .event: return 0.20
        case .steady: return 0.12
        case .afterhours: return 0.16
        case .minor: return 0.08
        }
    }

    var labelShadowOpacity: Double {
        switch self {
        case .hot: return 0.12
        case .event: return 0.10
        case .steady, .afterhours: return 0.06
        case .minor: return 0.04
        }
    }
}

private extension Venue {
    var mapPinSignal: NoctoMapPinSignal {
        switch noctoState {
        case .hot: return .hot
        case .event: return .event
        case .afterhours: return .afterhours
        case .steady: return .steady
        }
    }

    var mapPinTint: Color {
        switch mapPinSignal {
        case .hot: return NoctoTheme.accent
        case .event: return NoctoTheme.event
        case .steady: return Color(hex: "#CC3A63")
        case .afterhours: return NoctoTheme.signalAfter
        case .minor: return NoctoTheme.afterhoursBlue
        }
    }

    var mapPinLabelColor: Color {
        switch mapPinSignal {
        case .hot: return NoctoTheme.accentLight
        case .event: return NoctoTheme.event
        case .steady: return NoctoTheme.textPrimary
        case .afterhours: return NoctoTheme.signalAfter
        case .minor: return .clear
        }
    }

    var mapPinTitle: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return htmlCardName }

        if trimmed.count <= 14 {
            return trimmed
        }

        return String(trimmed.prefix(12)) + "…"
    }

    func mapPinSize(isSelected: Bool) -> CGFloat {
        let base: CGFloat
        switch mapPinSignal {
        case .hot, .event: base = 14
        case .steady: base = 11
        case .afterhours: base = 9
        case .minor: base = 8
        }

        return isSelected ? base + 2 : base
    }

    func mapPinRingInset(isSelected: Bool) -> CGFloat {
        let base: CGFloat
        switch mapPinSignal {
        case .hot: base = 10
        case .event: base = 14
        case .steady, .afterhours: base = 8
        case .minor: base = 6
        }

        return isSelected ? base + 2 : base
    }

    func mapPinRings(isSelected: Bool) -> Int {
        switch mapPinSignal {
        case .hot: return isSelected ? 3 : 2
        case .event: return 3
        case .steady, .afterhours, .minor: return isSelected ? 2 : 1
        }
    }

    var mapSheetMeta: String {
        switch noctoState {
        case .hot: return "\(noctoDistanceLabel) · Pulse \(noctoState.pulseScore)%"
        case .event: return "\(noctoDistanceLabel) · Tonight only"
        case .afterhours: return "\(noctoDistanceLabel) · след 01:30"
        case .steady: return "\(noctoDistanceLabel) · \(signalLabel)"
        }
    }

    var mapBadgeText: String {
        noctoState.badgeText
    }
}

private struct NoctoDeadMapDot: View {
    var size: CGFloat
    var color: Color = Color(hex: "#343343")

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.18))
                .frame(width: size * 2.8, height: size * 2.8)
                .blur(radius: 2)

            Circle()
                .fill(color.opacity(0.78))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.035), lineWidth: 1)
                )
        }
    }
}

private struct NoctoUserMapDot: View {
    let scale: CGFloat

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 13 * scale, height: 13 * scale)
            .shadow(color: Color.white.opacity(0.55), radius: 9 * scale)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 4 * scale)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 8 * scale)
            )
    }
}

private struct NoctoHTMLMapLegend: View {
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 5 * scale) {
            legend("Горещо", color: NoctoTheme.accent, glow: true)
            legend("Event", color: NoctoTheme.event, glow: true)
            legend("Afterhours", color: NoctoTheme.signalAfter, glow: true)
            legend("Затворено", color: NoctoTheme.signalDead, text: Color(hex: "#1A1428"))
        }
        .padding(.horizontal, 10 * scale)
        .padding(.vertical, 8 * scale)
        .background(
            RoundedRectangle(cornerRadius: 10 * scale)
                .fill(Color(hex: "#03020C").opacity(0.90))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10 * scale)
                .stroke(NoctoTheme.accent.opacity(0.10), lineWidth: 1)
        )
    }

    private func legend(_ label: String, color: Color, glow: Bool = false, text: Color = Color(hex: "#805466")) -> some View {
        HStack(spacing: 6 * scale) {
            Circle()
                .fill(color)
                .frame(width: 7 * scale, height: 7 * scale)
                .overlay(
                    Circle()
                        .stroke(color.opacity(glow ? 0.20 : 0.08), lineWidth: 2 * scale)
                )
                .shadow(color: glow ? color.opacity(0.28) : .clear, radius: 6 * scale)

            Text(label)
                .font(.system(size: 7 * scale, weight: .bold))
                .tracking(1 * scale)
                .textCase(.uppercase)
                .foregroundStyle(text)
        }
    }
}

private struct NoctoHTMLMapSheet: View {
    let venues: [Venue]
    let selectedVenue: Venue?
    let scale: CGFloat
    let onSelect: (Venue) -> Void

    private var sheetVenues: [Venue] {
        let featured = Array(venues.prefix(3))

        guard let selectedVenue else {
            return featured
        }

        return Array(featured.filter { $0.id != selectedVenue.id }.prefix(2))
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(hex: "#3A1B25"))
                .frame(width: 28 * scale, height: 3 * scale)
                .padding(.bottom, 10 * scale)

            if let selectedVenue {
                selectedRouteSummary(selectedVenue)
                    .padding(.bottom, 10 * scale)
            } else {
                Text("Близо до теб, тази вечер")
                    .font(.system(size: 7 * scale, weight: .bold))
                    .tracking(3 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(NoctoTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 9 * scale)
            }

            ForEach(Array(sheetVenues.enumerated()), id: \.element.id) { index, venue in
                row(
                    venue: venue,
                    isSelected: selectedVenue?.id == venue.id,
                    last: index == sheetVenues.count - 1
                )
            }
        }
        .padding(.horizontal, 14 * scale)
        .padding(.vertical, (selectedVenue == nil ? 13 : 10) * scale)
        .background(
            RoundedRectangle(cornerRadius: 18 * scale)
                .fill(Color(hex: "#05030E").opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18 * scale)
                .stroke(NoctoTheme.accent.opacity(0.10), lineWidth: 1)
        )
    }

    private func selectedRouteSummary(_ venue: Venue) -> some View {
        HStack(alignment: .center, spacing: 10 * scale) {
            ZStack {
                Circle()
                    .fill(venue.mapPinTint.opacity(0.18))
                    .frame(width: 34 * scale, height: 34 * scale)
                    .blur(radius: 2 * scale)

                NoctoRouteArrowGlyph()
                    .fill(NoctoTheme.signalAfter)
                    .frame(width: 15 * scale, height: 18 * scale)
                    .rotationEffect(.degrees(28))
                    .shadow(color: NoctoTheme.signalAfter.opacity(0.55), radius: 7 * scale)
            }

            VStack(alignment: .leading, spacing: 2 * scale) {
                Text("АКТИВЕН ФОКУС")
                    .font(.system(size: 6 * scale, weight: .bold))
                    .tracking(2 * scale)
                    .foregroundStyle(NoctoTheme.signalAfter)

                Text(venue.name)
                    .font(.system(size: 12 * scale, weight: .heavy))
                    .foregroundStyle(NoctoTheme.textPrimary)
                    .lineLimit(1)

                Text("\(venue.noctoDistanceLabel) · \(venue.noctoState.pulseScore)% pulse · \(venue.signalLabel)")
                    .font(.system(size: 7 * scale, weight: .medium))
                    .foregroundStyle(NoctoTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 6 * scale)

            Text("GO")
                .font(.system(size: 8 * scale, weight: .heavy))
                .tracking(1.5 * scale)
                .foregroundStyle(NoctoTheme.background)
                .padding(.horizontal, 8 * scale)
                .padding(.vertical, 5 * scale)
                .background(
                    Capsule()
                        .fill(NoctoTheme.signalAfter)
                )
        }
        .padding(.horizontal, 10 * scale)
        .padding(.vertical, 9 * scale)
        .background(
            RoundedRectangle(cornerRadius: 12 * scale)
                .fill(NoctoTheme.signalAfter.opacity(0.055))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12 * scale)
                .stroke(NoctoTheme.signalAfter.opacity(0.16), lineWidth: 1)
        )
    }

    private func row(venue: Venue, isSelected: Bool, last: Bool = false) -> some View {
        NavigationLink {
            VenueDetailView(venue: venue)
        } label: {
            HStack(spacing: 9 * scale) {
                NoctoCrestView(tint: venue.mapPinTint, eventDot: venue.noctoState == .event ? NoctoTheme.gold : nil)
                    .frame(width: 22 * scale, height: 22 * scale)

                VStack(alignment: .leading, spacing: 1 * scale) {
                    Text(venue.name)
                        .font(.system(size: 10 * scale, weight: .heavy))
                        .foregroundStyle(NoctoTheme.textPrimary)
                        .lineLimit(1)

                    Text(venue.mapSheetMeta)
                        .font(.system(size: 7 * scale, weight: .regular))
                        .tracking(0.5 * scale)
                        .foregroundStyle(NoctoTheme.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8 * scale)

                Text(venue.mapBadgeText)
                    .font(.system(size: 7 * scale, weight: .bold))
                    .tracking(1 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(venue.noctoState.accent)
                    .lineLimit(1)
                    .padding(.horizontal, 7 * scale)
                    .padding(.vertical, 2 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 3 * scale)
                            .fill(venue.noctoState.accent.opacity(venue.noctoState == .afterhours ? 0.08 : 0.12))
                    )
            }
            .padding(.vertical, 6 * scale)
            .background(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .fill(isSelected ? venue.mapPinTint.opacity(0.055) : .clear)
            )
            .overlay(alignment: .bottom) {
                if !last {
                    Rectangle()
                        .fill(Color.white.opacity(0.03))
                        .frame(height: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            TapGesture().onEnded {
                onSelect(venue)
            }
        )
    }
}

private enum VisualFallbackVenue {
    static func make() -> Venue {
        Venue(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            name: "Yalta Club",
            type: .club,
            description: "NOCTO visual fallback",
            latitude: 42.6977,
            longitude: 23.3219,
            address: "Sofia",
            workingHours: "23:00-06:00"
        )
    }
}
