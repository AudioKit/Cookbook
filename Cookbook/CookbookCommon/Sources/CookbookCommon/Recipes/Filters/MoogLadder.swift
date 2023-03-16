import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: One of the coolest filters available in AudioKit is the Moog Ladder.
//: It's based off of Robert Moog's iconic ladder filter, which was the
//: first implementation of a voltage - controlled filter used in an
//: analog synthesizer. As such, it was the first filter that gave the
//: ability to use voltage control to determine the cutoff frequency of the
//: filter. As we're dealing with a software implementation, and not an
//: analog synthesizer, we don't have to worry about dealing with
//: voltage control directly. However, by using this node, you can
//: emulate some of the sounds of classic analog synthesizers in your app.

class MoogLadderConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: MoogLadder
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = MoogLadder(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }
}

struct MoogLadderView: View {
    @StateObject var conductor = MoogLadderConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.filter.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.filter,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Moog Ladder")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
