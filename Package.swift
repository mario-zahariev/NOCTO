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
    targets: [
        .target(name: "NOCTOCore"),
        .target(
            name: "NOCTOAppLogic",
            dependencies: ["NOCTOCore"],
            path: "NOCTO",
            sources: ["OperationalSnapshot.swift"]
        ),
        .testTarget(name: "NOCTOCoreTests", dependencies: ["NOCTOCore"]),
        .testTarget(
            name: "OperationalSnapshotTests",
            dependencies: ["NOCTOAppLogic", "NOCTOCore"]
        )
    ]
)
