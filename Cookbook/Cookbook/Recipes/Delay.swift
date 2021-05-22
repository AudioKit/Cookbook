import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

// It's very common to mix exactly two inputs, one before processing occurs,
// and one after, resulting in a combination of the two.  This is so common
// that many of the AudioKit nodes have a dry/wet mix parameter built in.
//  But, if you are building your own custom effects, or making a long chain
// of effects, you can use DryWetMixer to blend your signals.

struct DelayData {
    var time: AUValue = 0.1
    var feedback: AUValue = 90
    var balance: AUValue = 0.5
}

class DelayConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let delay: Delay
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        delay = Delay(player)
        dryWetMixer = DryWetMixer(player, delay)
        engine.output = dryWetMixer
    }

    @Published var data = DelayData() {
        didSet {
            // When AudioKit uses an Apple AVAudioUnit, like the case here, the values can't be ramped
            delay.time = data.time
            delay.feedback = data.feedback
            delay.dryWetMix = 100
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        delay.feedback = 0.9
        delay.time = 0.01

        // We're not using delay's built in dry wet mix because
        // we are tapping the wet result so it can be plotted,
        // so just hard coding the delay to fully on
        delay.dryWetMix = 100

        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct DelayView: View {
    @StateObject var conductor = DelayConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Time",
                            parameter: self.$conductor.data.time,
                            range: 0...1,
                            units: "Seconds")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0...99,
                            units: "Percent-0-100")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "Percent")
            DryWetMixView(dry: conductor.player, wet: conductor.delay, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Delay"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
