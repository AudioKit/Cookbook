import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct EqualizerFilterData {
    var centerFrequency: AUValue = 1000.0
    var bandwidth: AUValue = 100.0
    var gain: AUValue = 10.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class EqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: EqualizerFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = EqualizerFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = EqualizerFilterData() {
        didSet {
            filter.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            filter.$bandwidth.ramp(to: data.bandwidth, duration: data.rampDuration)
            filter.$gain.ramp(to: data.gain, duration: data.rampDuration)
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

struct EqualizerFilterView: View {
    @StateObject var conductor = EqualizerFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Center Frequency",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0 ... 20000.0,
                            units: "Hertz")
            ParameterSlider(text: "Bandwidth",
                            parameter: self.$conductor.data.bandwidth,
                            range: 0.0 ... 20000.0,
                            units: "Hertz")
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: -100.0 ... 100.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Equalizer Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct EqualizerFilter_Previews: PreviewProvider {
    static var previews: some View {
        EqualizerFilterView()
    }
}
