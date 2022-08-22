import AudioKit
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
            HStack(spacing: 50) {
                ForEach(conductor.equalizer.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.equalizer,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("High Shelf Parametric Equalizer Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
