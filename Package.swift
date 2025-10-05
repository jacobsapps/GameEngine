// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GameEngine",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
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