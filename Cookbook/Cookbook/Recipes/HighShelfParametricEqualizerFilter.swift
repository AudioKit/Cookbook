import AudioKit
import AVFoundation
import SwiftUI

struct HighShelfParametricEqualizerFilterData {
    var centerFrequency: AUValue = 1_000
    var gain: AUValue = 1.0
    var q: AUValue = 0.707
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class HighShelfParametricEqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let equalizer: HighShelfParametricEqualizerFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let equalizerPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        equalizer = HighShelfParametricEqualizerFilter(player)
        dryWetMixer = DryWetMixer(player, equalizer)
        playerPlot = NodeOutputPlot(player)
        equalizerPlot = NodeOutputPlot(equalizer)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, equalizerPlot, mixPlot)
    }

    @Published var data = HighShelfParametricEqualizerFilterData() {
        didSet {
            equalizer.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            equalizer.$gain.ramp(to: data.gain, duration: data.rampDuration)
            equalizer.$q.ramp(to: data.q, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        equalizerPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct HighShelfParametricEqualizerFilterView: View {
    @ObservedObject var conductor = HighShelfParametricEqualizerFilterConductor()

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
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.equalizerPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("High Shelf Parametric Equalizer Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct HighShelfParametricEqualizerFilter_Previews: PreviewProvider {
    static var previews: some View {
        HighShelfParametricEqualizerFilterView()
    }
}
