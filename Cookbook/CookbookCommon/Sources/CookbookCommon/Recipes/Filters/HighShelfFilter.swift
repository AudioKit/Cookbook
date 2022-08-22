import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct HighShelfFilterData {
    var cutoffFrequency: AUValue = 1000
    var gain: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class HighShelfFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: HighShelfFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = HighShelfFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = HighShelfFilterData() {
        didSet {
            filter.cutOffFrequency = data.cutoffFrequency
            filter.gain = data.gain
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

struct HighShelfFilterView: View {
    @StateObject var conductor = HighShelfFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0 ... 10000.0,
                            units: "Hertz")
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: -40 ... 40,
                            units: "dB")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("High Shelf Filter")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct HighShelfFilter_Previews: PreviewProvider {
    static var previews: some View {
        HighShelfFilterView()
    }
}
