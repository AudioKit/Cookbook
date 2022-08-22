import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: ## Multi-tap Delay
//: A multi-tap delay is a delay line where multiple 'taps' or outputs are
//: taken from a delay buffer at different points, and the taps are then
//: summed with the original. Multi-tap delays are great for creating
//: rhythmic delay patterns, but they can also be used to create sound
//: fields of such density that they start to take on some of the qualities
//: we'd more usually associate with reverb. - Geoff Smith, Sound on Sound

class MultiTapDelayConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        var delays = [VariableDelay]()

        func multitapDelay(_ input: Node, times: [AUValue], gains: [AUValue]) -> Mixer {
            let mix = Mixer(input)
            var counter = 0
            zip(times, gains).forEach { time, gain in
                delays.append(VariableDelay(input, time: time))
                mix.addInput(Fader(delays[counter], gain: gain))
                counter += 1
            }
            return mix
        }

        engine.output = multitapDelay(player, times: [0.1, 0.2, 0.4], gains: [0.5, 2.0, 0.5])
    }
}

struct MultiTapDelayView: View {
    @StateObject var conductor = MultiTapDelayConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("""
            A multi-tap delay is a delay line where multiple 'taps' or outputs are taken from a delay buffer at different points, and the taps are then summed with the original. Multi-tap delays are great for creating rhythmic delay patterns, but they can also be used to create sound fields of such density that they start to take on some of the qualities we'd more usually associate with reverb.

            - Geoff Smith, Sound on Sound
            """)
            PlayerControls(conductor: conductor)
        }
        .padding()
        .cookbookNavBarTitle("MultiTap Delay Operation")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
