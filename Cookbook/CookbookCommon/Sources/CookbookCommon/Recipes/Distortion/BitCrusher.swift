import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class BitCrusherConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let bitcrusher: BitCrusher
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        bitcrusher = BitCrusher(player)
        dryWetMixer = DryWetMixer(player, bitcrusher)
        engine.output = dryWetMixer
    }
}

struct BitCrusherView: View {
    @StateObject var conductor = BitCrusherConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.bitcrusher.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.bitcrusher,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Bit Crusher")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
