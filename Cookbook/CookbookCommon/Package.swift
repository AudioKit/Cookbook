// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "CookbookCommon",
    platforms: [.macOS(.v12), .iOS(.v16), .tvOS(.v15)],
    products: [.library(name: "CookbookCommon", targets: ["CookbookCommon"])],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit",          from: "5.6.4"),
        .package(url: "https://github.com/AudioKit/AudioKitUI",        branch: "visionos"),
        .package(url: "https://github.com/AudioKit/AudioKitEX",        from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/Controls",          from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/DunneAudioKit",     from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/Keyboard",          from: "1.3.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/SporthAudioKit",    from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/STKAudioKit",       from: "5.5.0"),
        .package(url: "https://github.com/AudioKit/Tonic",             from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/Waveform",          branch: "visionos"),
        .package(url: "https://github.com/AudioKit/Flow",              from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/PianoRoll",         from: "1.0.0"),
        .package(url: "https://github.com/orchetect/MIDIKit",          from: "0.9.7"),
    ],
    targets: [
        .target(
            name: "CookbookCommon",
            dependencies: ["AudioKit", "AudioKitUI", "AudioKitEX", "Keyboard", "SoundpipeAudioKit",
                           "SporthAudioKit", "STKAudioKit", "DunneAudioKit", "Tonic", "Controls", "Waveform", "Flow", "PianoRoll", "MIDIKit"],
            resources: [
                .copy("MIDI Files"),
                .copy("Samples"),
                .copy("Impulse Responses"),
            ]
        ),
        .testTarget(name: "CookbookCommonTests", dependencies: ["CookbookCommon"]),
    ]
)
