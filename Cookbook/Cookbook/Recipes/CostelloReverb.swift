import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct CostelloReverbData {
    var feedback: AUValue = 0.6
    var cutoffFrequency: AUValue = 4_000.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class CostelloReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: CostelloReverb
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        reverb = CostelloReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        engine.output = dryWetMixer
    }

    @Published var data = CostelloReverbData() {
        didSet {
            reverb.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
            reverb.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
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

struct CostelloReverbView: View {
    @StateObject var conductor = CostelloReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.reverb, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Costello Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct CostelloReverb_Previews: PreviewProvider {
    static var previews: some View {
        CostelloReverbView()
    }
}
