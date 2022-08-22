import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct StringResonatorData {
    var fundamentalFrequency: AUValue = 100
    var feedback: AUValue = 0.95
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class StringResonatorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: StringResonator
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = StringResonator(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = StringResonatorData() {
        didSet {
            filter.$fundamentalFrequency.ramp(to: data.fundamentalFrequency, duration: data.rampDuration)
            filter.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct StringResonatorView: View {
    @StateObject var conductor = StringResonatorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Fundamental Frequency",
                            parameter: self.$conductor.data.fundamentalFrequency,
                            range: 12.0 ... 10000.0,
                            units: "Hertz")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0.0 ... 1.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("String Resonator")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct StringResonator_Previews: PreviewProvider {
    static var previews: some View {
        StringResonatorView()
    }
}
