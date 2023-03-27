import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

// With TimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.

struct TimePitchData {
    var rate: AUValue = 2.0
    var pitch: AUValue = -400
}

class TimePitchConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let timePitch: TimePitch
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        timePitch = TimePitch(player)
        timePitch.rate = 2.0
        timePitch.pitch = -400.0
        engine.output = timePitch
    }

    @Published var data = TimePitchData() {
        didSet {
            // When AudioKit uses an Apple AVAudioUnit, like the case here, the values can't be ramped
            timePitch.rate = data.rate
            timePitch.pitch = data.pitch
        }
    }

}

struct TimePitchView: View {
    @StateObject var conductor = TimePitchConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)

            HStack {
                CookbookKnob(text: "Rate",
                                parameter: self.$conductor.data.rate,
                                range: 0.3125 ... 5,
                                units: "Generic")
                CookbookKnob(text: "Pitch",
                                parameter: self.$conductor.data.pitch,
                                range: -2400 ... 2400,
                                units: "Cents")
            }
            NodeOutputView(conductor.timePitch)
        }
        .padding()
        .cookbookNavBarTitle("Time / Pitch")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
