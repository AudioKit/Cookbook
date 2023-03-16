import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class TransientShaperConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let transientshaper: TransientShaper
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        transientshaper = TransientShaper(player)
        dryWetMixer = DryWetMixer(player, transientshaper)
        engine.output = dryWetMixer
    }
}

struct TransientShaperView: View {
    @StateObject var conductor = TransientShaperConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.transientshaper.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.transientshaper,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Transient Shaper")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
