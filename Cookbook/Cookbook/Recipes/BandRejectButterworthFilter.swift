import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct BandRejectButterworthFilterData {
    var centerFrequency: AUValue = 3_000.0
    var bandwidth: AUValue = 2_000.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class BandRejectButterworthFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: BandRejectButterworthFilter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = BandRejectButterworthFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        engine.output = dryWetMixer
    }

    @Published var data = BandRejectButterworthFilterData() {
        didSet {
            filter.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            filter.$bandwidth.ramp(to: data.bandwidth, duration: data.rampDuration)
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

struct BandRejectButterworthFilterView: View {
    @ObservedObject var conductor = BandRejectButterworthFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Center Frequency",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Bandwidth",
                            parameter: self.$conductor.data.bandwidth,
                            range: 0.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.filter, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Band Reject Butterworth Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct BandRejectButterworthFilter_Previews: PreviewProvider {
    static var previews: some View {
        BandRejectButterworthFilterView()
    }
}
