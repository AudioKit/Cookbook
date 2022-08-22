import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class FlatFrequencyResponseReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: FlatFrequencyResponseReverb
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        reverb = FlatFrequencyResponseReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        engine.output = dryWetMixer
    }
}

struct FlatFrequencyResponseReverbView: View {
    @StateObject var conductor = FlatFrequencyResponseReverbConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.reverb.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.reverb,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Flat Frequency Response Reverb")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
