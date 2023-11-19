// swift-tools-version: 5.9
import PackageDescription

let devModeInXcode = false

let package = Package(
    name: "Reducer",
    platforms: [.macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v4)],
    products: [
        .library(name: "Reducer", targets: ["Reducer"])
    ].compactMap { $0 },
    targets: [
        .target(
            name: "Reducer",
            dependencies: [],
            plugins: devModeInXcode ? ["SwiftLintXcode"] : []
        ),
        .testTarget(name: "ReducerTests", dependencies: ["Reducer"])
    ] + (devModeInXcode ? [
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.54.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "963121d6babf2bf5fd66a21ac9297e86d855cbc9d28322790646b88dceca00f1"
        ),
        .plugin(
            name: "SwiftLintXcode",
            capability: .buildTool(),
            dependencies: ["SwiftLintBinary"]
        )
    ] : []),
    swiftLanguageVersions: [.v5]
)
