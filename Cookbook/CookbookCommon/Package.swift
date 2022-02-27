// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CookbookCommon",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CookbookCommon",
            targets: ["CookbookCommon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit", branch: "develop"),
        .package(url: "https://github.com/AudioKit/AudioKitUI", branch: "develop"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit", branch: "develop"),
        .package(url: "https://github.com/AudioKit/AudioKitEX", from: Version(5, 3, 2)),
        .package(url: "https://github.com/AudioKit/SporthAudioKit", from: Version(5, 3, 1)),
        .package(url: "https://github.com/AudioKit/STKAudioKit", from: Version(5, 3, 0)),
        .package(url: "https://github.com/AudioKit/DunneAudioKit", from: Version(5, 3, 1)),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CookbookCommon",
            dependencies: ["AudioKit", "AudioKitUI", "AudioKitEX", "SoundpipeAudioKit", "SporthAudioKit", "STKAudioKit", "DunneAudioKit"],
            resources: [
                .copy("Resources"),
                .copy("Samples"),
                .copy("Sounds"),
                .copy("Impulse Responses")]),
        .testTarget(
            name: "CookbookCommonTests",
            dependencies: ["CookbookCommon"]),
    ]
)
