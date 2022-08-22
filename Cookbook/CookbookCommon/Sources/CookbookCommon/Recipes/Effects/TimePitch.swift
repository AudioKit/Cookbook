import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

// With TimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.

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
}

struct TimePitchView: View {
    @StateObject var conductor = TimePitchConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.timePitch.parameters) {
                    ParameterEditor2(param: $0)
                }
            }
        }
        .padding()
        .cookbookNavBarTitle("Time / Pitch")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
