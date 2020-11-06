import AudioKit
import AVFoundation
import SwiftUI

struct TremoloData {
    var frequency: AUValue = 10.0
    var depth: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class TremoloConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer2()
    let tremolo: Tremolo
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let tremoloPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        tremolo = Tremolo(player)
        dryWetMixer = DryWetMixer(player, tremolo)
        playerPlot = NodeOutputPlot(player)
        tremoloPlot = NodeOutputPlot(tremolo)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, tremoloPlot, mixPlot)
    }

    @Published var data = TremoloData() {
        didSet {
            tremolo.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            tremolo.$depth.ramp(to: data.depth, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        tremoloPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct TremoloView: View {
    @ObservedObject var conductor = TremoloConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0.0...200.0,
                            units: "Hertz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.tremoloPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Tremolo"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Tremolo_Previews: PreviewProvider {
    static var previews: some View {
        TremoloView()
    }
}
