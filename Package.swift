// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Reducer",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(name: "Reducer", targets: ["Reducer"])
    ],
    targets: [
        .target(name: "Reducer"),
        .testTarget(name: "ReducerTests", dependencies: ["Reducer"])
    ],
    swiftLanguageVersions: [.v5]
)
