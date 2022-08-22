import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class TanhDistortionConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let distortion: TanhDistortion
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        distortion = TanhDistortion(player)
        dryWetMixer = DryWetMixer(player, distortion)
        engine.output = dryWetMixer
    }
}

struct TanhDistortionView: View {
    @StateObject var conductor = TanhDistortionConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.distortion.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.distortion,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Tanh Distortion")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
