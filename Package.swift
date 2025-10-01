// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GameEngine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GameEngine",
            targets: ["GameEngine"])
    ],
    targets: [
        .target(
            name: "GameEngine",
            dependencies: [])
    ]
)