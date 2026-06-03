// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "NOCTOCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "NOCTOCore", targets: ["NOCTOCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0")
    ],
    targets: [
        .target(name: "NOCTOCore"),
        .target(
            name: "NOCTOAppLogic",
            dependencies: ["NOCTOCore"],
            path: "NOCTO",
            exclude: [
                "AdminDashboardView.swift",
                "AllVenuesMapView.swift",
                "Assets.xcassets",
                "BlurView.swift",
                "Color+Hex.swift",
                "ContentView.swift",
                "FavoritesManager.swift",
                "FavoritesView.swift",
                "GoogleService-Info.plist.example",
                "Haptics.swift",
                "HeroParallaxCard.swift",
                "HomeView.swift",
                "LiveActivitySignalViews.swift",
                "LocationManager.swift",
                "MicroFeedback.swift",
                "NOCTOApp.swift",
                "NightPulseView.swift",
                "NoctoAttributes.swift",
                "NoctoLiveActivityHandler.swift",
                "NoctoTheme.swift",
                "ParallaxCard.swift",
                "ProfileView.swift",
                "VenueCard.swift",
                "VenueCatalogView.swift",
                "VenueDetailView.swift",
                "Venue.swift"
            ],
            sources: [
                "OperationalSnapshot.swift",
                "VenueCatalogViewModel.swift",
                "VenueDataSource.swift",
                "VenueRepository.swift"
            ]
        ),
        .testTarget(name: "NOCTOCoreTests", dependencies: ["NOCTOCore"]),
        .testTarget(
            name: "OperationalSnapshotTests",
            dependencies: ["NOCTOAppLogic", "NOCTOCore"]
        ),
        .testTarget(
            name: "ArchitectureGuardTests",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        )
    ]
)
