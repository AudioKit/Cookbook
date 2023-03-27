import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PhaserConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let phaser: Phaser
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        phaser = Phaser(player)
        dryWetMixer = DryWetMixer(player, phaser)
        engine.output = dryWetMixer
    }
}

struct PhaserView: View {
    @StateObject var conductor = PhaserConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.phaser.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.phaser,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Phaser")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
