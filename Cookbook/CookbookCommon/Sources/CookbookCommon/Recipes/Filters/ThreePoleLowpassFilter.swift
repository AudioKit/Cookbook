import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class ThreePoleLowpassFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: ThreePoleLowpassFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = ThreePoleLowpassFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

}

struct ThreePoleLowpassFilterView: View {
    @StateObject var conductor = ThreePoleLowpassFilterConductor()

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
        .cookbookNavBarTitle("Three Pole Lowpass Filter")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
