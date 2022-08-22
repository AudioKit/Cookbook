import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PannerConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let panner: Panner
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        panner = Panner(player)
        dryWetMixer = DryWetMixer(player, panner)
        engine.output = dryWetMixer
    }
}

struct PannerView: View {
    @StateObject var conductor = PannerConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.panner.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.panner,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Panner")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
