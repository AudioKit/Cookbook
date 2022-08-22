import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class EqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: EqualizerFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = EqualizerFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

}

struct EqualizerFilterView: View {
    @StateObject var conductor = EqualizerFilterConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.filter.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.filter,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Equalizer Filter")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
