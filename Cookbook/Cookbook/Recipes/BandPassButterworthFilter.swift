import AudioKit
import AVFoundation
import SwiftUI

//: Band-pass filters allow audio above a specified frequency range and
//: bandwidth to pass through to an output. The center frequency is the starting point
//: from where the frequency limit is set. Adjusting the bandwidth sets how far out
//: above and below the center frequency the frequency band should be.
//: Anything above that band should pass through.
struct BandPassButterworthFilterData {
    var centerFrequency: AUValue = 2_000.0
    var bandwidth: AUValue = 100.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class BandPassButterworthFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: BandPassButterworthFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let filterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        filter = BandPassButterworthFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        playerPlot = NodeOutputPlot(player)
        filterPlot = NodeOutputPlot(filter)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, filterPlot, mixPlot)
    }

    @Published var data = BandPassButterworthFilterData() {
        didSet {
            filter.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            filter.$bandwidth.ramp(to: data.bandwidth, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct BandPassButterworthFilterView: View {
    @ObservedObject var conductor = BandPassButterworthFilterConductor()

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
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Band Pass Butterworth Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct BandPassButterworthFilter_Previews: PreviewProvider {
    static var previews: some View {
        BandPassButterworthFilterView()
    }
}
