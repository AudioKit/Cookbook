import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class CostelloReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: CostelloReverb
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        reverb = CostelloReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        engine.output = dryWetMixer
    }
}

struct CostelloReverbView: View {
    @StateObject var conductor = CostelloReverbConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.reverb.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.reverb,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Costello Reverb")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
