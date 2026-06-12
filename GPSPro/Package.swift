// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GPSPro",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "GPSProLib", targets: ["GPSProLib"])
    ],
    targets: [
        .target(
            name: "GPSProLib",
            path: "Sources",
            resources: [.process("Resources")]
        )
    ]
)