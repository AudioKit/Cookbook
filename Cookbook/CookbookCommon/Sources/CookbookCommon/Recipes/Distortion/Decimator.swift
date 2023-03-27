import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: Decimation is a type of digital distortion like bit crushing,
//: but instead of directly stating what bit depth and sample rate you want,
//: it is done through setting "decimation" and "rounding" parameters.

class DecimatorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let decimator: Decimator
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        decimator = Decimator(player)
        decimator.finalMix = 100
        dryWetMixer = DryWetMixer(player, decimator)
        engine.output = dryWetMixer
    }
}

struct DecimatorView: View {
    @StateObject var conductor = DecimatorConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.decimator.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.decimator,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Decimator")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
