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
        .testTarget(name: "NOCTOCoreTests", dependencies: ["NOCTOCore"])
    ]
)
