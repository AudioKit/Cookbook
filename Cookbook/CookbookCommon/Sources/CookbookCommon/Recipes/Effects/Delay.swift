import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

// It's very common to mix exactly two inputs, one before processing occurs,
// and one after, resulting in a combination of the two.  This is so common
// that many of the AudioKit nodes have a dry/wet mix parameter built in.
//  But, if you are building your own custom effects, or making a long chain
// of effects, you can use DryWetMixer to blend your signals.

class DelayConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let delay: Delay
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        delay = Delay(player)
        delay.feedback = 0.9
        delay.time = 0.01

        // We're not using delay's built in dry wet mix because
        // we are tapping the wet result so it can be plotted.
        delay.dryWetMix = 100
        dryWetMixer = DryWetMixer(player, delay)
        engine.output = dryWetMixer
    }
}

struct DelayView: View {
    @StateObject var conductor = DelayConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.delay.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.delay,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Delay")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
