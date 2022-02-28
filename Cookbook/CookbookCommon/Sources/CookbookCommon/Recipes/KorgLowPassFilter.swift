import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct KorgLowPassFilterData {
    var cutoffFrequency: AUValue = 1_000.0
    var resonance: AUValue = 1.0
    var saturation: AUValue = 0.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class KorgLowPassFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: KorgLowPassFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = KorgLowPassFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = KorgLowPassFilterData() {
        didSet {
            filter.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
            filter.$resonance.ramp(to: data.resonance, duration: data.rampDuration)
            filter.$saturation.ramp(to: data.saturation, duration: data.rampDuration)
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

struct KorgLowPassFilterView: View {
    @StateObject var conductor = KorgLowPassFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 0.0...22_050.0,
                            units: "Hertz")
            ParameterSlider(text: "Resonance",
                            parameter: self.$conductor.data.resonance,
                            range: 0.0...2.0,
                            units: "Generic")
            ParameterSlider(text: "Saturation",
                            parameter: self.$conductor.data.saturation,
                            range: 0.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Korg Low Pass Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct KorgLowPassFilter_Previews: PreviewProvider {
    static var previews: some View {
        KorgLowPassFilterView()
    }
}
