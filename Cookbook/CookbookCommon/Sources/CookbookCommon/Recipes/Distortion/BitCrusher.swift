import AudioKit
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
            HStack(spacing: 50) {
                ForEach(conductor.bitcrusher.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.bitcrusher,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Bit Crusher")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
