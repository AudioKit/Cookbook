// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CookbookCommon",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CookbookCommon",
            targets: ["CookbookCommon"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit", from: "5.5.4"),
        .package(url: "https://github.com/AudioKit/AudioKitUI", branch: "main"),
        .package(url: "https://github.com/AudioKit/AudioKitEX", from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/Controls", from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/DunneAudioKit", from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/Keyboard", from: "1.3.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit", from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/SporthAudioKit", from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/Tonic", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CookbookCommon",
            dependencies: ["AudioKit", "AudioKitUI", "AudioKitEX", "Keyboard", "SoundpipeAudioKit", "SporthAudioKit", "DunneAudioKit", "Tonic", "Controls"],
            resources: [
                .copy("MIDI Files"),
                .copy("Samples"),
                .copy("Impulse Responses"),
            ]
        ),
        .testTarget(
            name: "CookbookCommonTests",
            dependencies: ["CookbookCommon"]
        ),
    ]
)
