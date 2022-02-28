import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct FormantFilterData {
    var centerFrequency: AUValue = 1_000
    var attackDuration: AUValue = 0.007
    var decayDuration: AUValue = 0.04
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class FormantFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: FormantFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = FormantFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = FormantFilterData() {
        didSet {
            filter.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            filter.$attackDuration.ramp(to: data.attackDuration, duration: data.rampDuration)
            filter.$decayDuration.ramp(to: data.decayDuration, duration: data.rampDuration)
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

struct FormantFilterView: View {
    @StateObject var conductor = FormantFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Center Frequency",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Attack Duration",
                            parameter: self.$conductor.data.attackDuration,
                            range: 0.0...0.1,
                            units: "Seconds")
            ParameterSlider(text: "Decay Duration",
                            parameter: self.$conductor.data.decayDuration,
                            range: 0.0...0.1,
                            units: "Seconds")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Formant Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct FormantFilter_Previews: PreviewProvider {
    static var previews: some View {
        FormantFilterView()
    }
}
