import AudioKit
import AVFoundation
import SwiftUI

struct PannerData {
    var pan: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PannerConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let panner: Panner
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let pannerPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        panner = Panner(player)
        dryWetMixer = DryWetMixer(player, panner)
        playerPlot = NodeOutputPlot(player)
        pannerPlot = NodeOutputPlot(panner)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        pannerPlot.plotType = .rolling
        pannerPlot.color = .blue
        pannerPlot.shouldFill = true
        pannerPlot.shouldMirror = true
        pannerPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = PannerData() {
        didSet {
            panner.$pan.ramp(to: data.pan, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        pannerPlot.start()
        mixPlot.start()

        do {
            try engine.start()
            // player stuff has to be done after start
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct PannerView: View {
    @ObservedObject var conductor = PannerConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Pan",
                            parameter: self.$conductor.data.pan,
                            range: -1...1,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.pannerPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Panner"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Panner_Previews: PreviewProvider {
    static var previews: some View {
        PannerView()
    }
}
