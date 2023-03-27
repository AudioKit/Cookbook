import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class RingModulatorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let ringModulator: RingModulator
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        ringModulator = RingModulator(player)
        dryWetMixer = DryWetMixer(player, ringModulator)
        engine.output = dryWetMixer
    }
}

struct RingModulatorView: View {
    @StateObject var conductor = RingModulatorConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.ringModulator.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.ringModulator,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Ring Modulator")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
