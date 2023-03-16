import AudioKit
import AudioKitEX
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
            HStack {
                ForEach(conductor.distortion.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
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
