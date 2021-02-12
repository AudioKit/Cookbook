import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct ChorusData {
    var frequency: AUValue = 1.0
    var depth: AUValue = 1.0
    var feedback: AUValue = 0.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ChorusConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let chorus: Chorus
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        chorus = Chorus(player)
        dryWetMixer = DryWetMixer(player, chorus)
        engine.output = dryWetMixer
    }

    @Published var data = ChorusData() {
        didSet {
            chorus.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            chorus.$depth.ramp(to: data.depth, duration: data.rampDuration)
            chorus.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
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

struct ChorusView: View {
    @ObservedObject var conductor = ChorusConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0.1...10.0,
                            units: "Hz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "%")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: -0.95...0.95,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.chorus, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Chorus"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Chorus_Previews: PreviewProvider {
    static var previews: some View {
        ChorusView()
    }
}
