import AudioKit
import AudioKitEX
import AudioKitUI
import SoundpipeAudioKit
import AVFoundation
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
            HStack(spacing: 50) {
                ForEach(conductor.clipper.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.clipper,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Clipper")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
