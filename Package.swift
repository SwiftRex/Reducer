// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Reducer",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(name: "Reducer", targets: ["Reducer"])
//        .plugin(name: "Linter", targets: ["SwiftLintPlugin"])
    ],
    targets: [
        .target(name: "Reducer"), // dependencies: ["SwiftLintPlugin"]),
        .testTarget(name: "ReducerTests", dependencies: ["Reducer"])
// Please keep it commented out. This should be uncommented only for when developing the library in Xcode
//        .binaryTarget(
//            name: "SwiftLintBinary",
//            url: "https://github.com/realm/SwiftLint/releases/download/0.50.0/SwiftLintBinary-macos.artifactbundle.zip",
//            checksum: "fb93e474e5827940985093c9cd437f1a70e511b16d790fe0e4150ab25edefa3b"
//        ),
//        .plugin(
//            name: "SwiftLintPlugin",
//            capability: .buildTool(),
//            dependencies: ["SwiftLintBinary"]
//        )
    ],
    swiftLanguageVersions: [.v5]
)
