import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct RolandTB303FilterData {
    var cutoffFrequency: AUValue = 500
    var resonance: AUValue = 0.5
    var distortion: AUValue = 2.0
    var resonanceAsymmetry: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class RolandTB303FilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: RolandTB303Filter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = RolandTB303Filter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = RolandTB303FilterData() {
        didSet {
            filter.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
            filter.$resonance.ramp(to: data.resonance, duration: data.rampDuration)
            filter.$distortion.ramp(to: data.distortion, duration: data.rampDuration)
            filter.$resonanceAsymmetry.ramp(to: data.resonanceAsymmetry, duration: data.rampDuration)
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

struct RolandTB303FilterView: View {
    @ObservedObject var conductor = RolandTB303FilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Resonance",
                            parameter: self.$conductor.data.resonance,
                            range: 0.0...2.0,
                            units: "Generic")
            ParameterSlider(text: "Distortion",
                            parameter: self.$conductor.data.distortion,
                            range: 0.0...4.0,
                            units: "Generic")
            ParameterSlider(text: "Resonance Asymmetry",
                            parameter: self.$conductor.data.resonanceAsymmetry,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView2(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Roland Tb303 Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct RolandTB303Filter_Previews: PreviewProvider {
    static var previews: some View {
        RolandTB303FilterView()
    }
}
