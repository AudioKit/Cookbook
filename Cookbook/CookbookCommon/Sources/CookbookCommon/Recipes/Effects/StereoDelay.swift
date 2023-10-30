import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

class StereoDelayConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let delay: StereoDelay
    var dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        delay = StereoDelay(player)
        dryWetMixer = DryWetMixer(player, delay)
        engine.output = dryWetMixer
    }
}

struct StereoDelayView: View {
    @StateObject var conductor = StereoDelayConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.delay.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.delay,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Stereo Delay")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
