import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct PeakingParametricEqualizerFilterData {
    var centerFrequency: AUValue = 1_000
    var gain: AUValue = 1.0
    var q: AUValue = 0.707
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PeakingParametricEqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let equalizer: PeakingParametricEqualizerFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        equalizer = PeakingParametricEqualizerFilter(player)
        dryWetMixer = DryWetMixer(player, equalizer)
        engine.output = dryWetMixer
    }

    @Published var data = PeakingParametricEqualizerFilterData() {
        didSet {
            equalizer.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            equalizer.$gain.ramp(to: data.gain, duration: data.rampDuration)
            equalizer.$q.ramp(to: data.q, duration: data.rampDuration)
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

struct PeakingParametricEqualizerFilterView: View {
    @StateObject var conductor = PeakingParametricEqualizerFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Center Frequency",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: 0.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Q",
                            parameter: self.$conductor.data.q,
                            range: 0.0...2.0,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.equalizer, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Peaking Parametric Equalizer Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PeakingParametricEqualizerFilter_Previews: PreviewProvider {
    static var previews: some View {
        PeakingParametricEqualizerFilterView()
    }
}
