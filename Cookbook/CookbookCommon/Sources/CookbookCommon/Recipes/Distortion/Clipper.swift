import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class ClipperConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let clipper: Clipper
    let amplifier: Fader
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        clipper = Clipper(player)
        amplifier = Fader(clipper)
        dryWetMixer = DryWetMixer(player, amplifier)
        engine.output = dryWetMixer
    }
}

struct ClipperView: View {
    @StateObject var conductor = ClipperConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.clipper.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.clipper,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Clipper")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
