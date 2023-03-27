import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

// This recipe uses the VariSpeed node to change the playback speed of a file (which also affects the pitch)
class PlaybackSpeedConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let variSpeed: VariSpeed
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        variSpeed = VariSpeed(player)
        variSpeed.rate = 2.0
        engine.output = variSpeed
    }

    @Published var rate: AUValue = 2.0 {
        didSet {
            variSpeed.rate = rate
        }
    }
}

struct PlaybackSpeedView: View {
    @StateObject var conductor = PlaybackSpeedConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            CookbookKnob(text: "Rate",
                            parameter: $conductor.rate,
                            range: 0.3125 ... 5,
                            units: "Generic")
            NodeRollingView(conductor.variSpeed)
        }
        .padding()
        .cookbookNavBarTitle("Playback Speed")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
