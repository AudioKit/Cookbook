import AudioKit
import AVFoundation
import SwiftUI

struct ResonantFilterData {
    var frequency: AUValue = 4_000.0
    var bandwidth: AUValue = 1_000.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ResonantFilterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: ResonantFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let filterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = ResonantFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        playerPlot = NodeOutputPlot(player)
        filterPlot = NodeOutputPlot(filter)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, filterPlot, mixPlot)
    }

    @Published var data = ResonantFilterData() {
        didSet {
            filter.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            filter.$bandwidth.ramp(to: data.bandwidth, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct ResonantFilterView: View {
    @ObservedObject var conductor = ResonantFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 100.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Bandwidth",
                            parameter: self.$conductor.data.bandwidth,
                            range: 0.0...10_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Resonant Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ResonantFilter_Previews: PreviewProvider {
    static var previews: some View {
        ResonantFilterView()
    }
}
