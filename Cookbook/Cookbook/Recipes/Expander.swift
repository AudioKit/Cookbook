import AudioKit
import AVFoundation
import SwiftUI

struct ExpanderData {
    var expansionRatio: AUValue = 2
    var expansionThreshold: AUValue = 2
    var attackTime: AUValue = 0.001
    var releaseTime: AUValue = 0.05
    var masterGain: AUValue = 0
    var balance: AUValue = 0.5
}

class ExpanderConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer2()
    let expander: Expander
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let expanderPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        expander = Expander(player)

        dryWetMixer = DryWetMixer(player, expander)
        playerPlot = NodeOutputPlot(player)
        expanderPlot = NodeOutputPlot(expander)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, expanderPlot, mixPlot)
    }

    @Published var data = ExpanderData() {
        didSet {
            expander.expansionRatio = data.expansionRatio
            expander.expansionThreshold = data.expansionThreshold
            expander.attackTime = data.attackTime
            expander.releaseTime = data.releaseTime
            expander.masterGain = data.masterGain
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        expanderPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct ExpanderView: View {
    @ObservedObject var conductor = ExpanderConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Ratio",
                            parameter: self.$conductor.data.expansionRatio,
                            range: 1...50,
                            units: "Generic")
            ParameterSlider(text: "Threshold",
                            parameter: self.$conductor.data.expansionThreshold,
                            range: 1...50,
                            units: "Generic")
            ParameterSlider(text: "Attack Duration",
                            parameter: self.$conductor.data.attackTime,
                            range: 0.001...0.2,
                            units: "Seconds")
            ParameterSlider(text: "Release Duration",
                            parameter: self.$conductor.data.releaseTime,
                            range: 0.01...3,
                            units: "Seconds")
            ParameterSlider(text: "Master Gain",
                            parameter: self.$conductor.data.masterGain,
                            range: -40...40,
                            units: "dB")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.expanderPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Expander"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Expander_Previews: PreviewProvider {
    static var previews: some View {
        ExpanderView()
    }
}
