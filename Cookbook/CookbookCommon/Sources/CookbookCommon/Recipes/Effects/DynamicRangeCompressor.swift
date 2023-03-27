import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class DynamicRangeCompressorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let compressor: DynamicRangeCompressor
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        compressor = DynamicRangeCompressor(player)
        dryWetMixer = DryWetMixer(player, compressor)
        engine.output = dryWetMixer
    }
}

struct DynamicRangeCompressorView: View {
    @StateObject var conductor = DynamicRangeCompressorConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.compressor.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.compressor,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Dynamic Range Compressor")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
