import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class HighShelfParametricEqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let equalizer: HighShelfParametricEqualizerFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        equalizer = HighShelfParametricEqualizerFilter(player)
        dryWetMixer = DryWetMixer(player, equalizer)
        engine.output = dryWetMixer
    }
}

struct HighShelfParametricEqualizerFilterView: View {
    @StateObject var conductor = HighShelfParametricEqualizerFilterConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.equalizer.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.equalizer,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("High Shelf Parametric Equalizer Filter")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
