import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: A peak limiter will set a hard limit on the amplitude of an audio signal.
//: They're especially useful for any type of live input processing, when you
//: may not be in total control of the audio signal you're recording or processing.

class PeakLimiterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let peakLimiter: PeakLimiter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        peakLimiter = PeakLimiter(player)
        dryWetMixer = DryWetMixer(player, peakLimiter)
        engine.output = dryWetMixer
    }
}

struct PeakLimiterView: View {
    @StateObject var conductor = PeakLimiterConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.peakLimiter.parameters) {
                    ParameterRow(param: $0)
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.peakLimiter,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("PeakLimiter")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
