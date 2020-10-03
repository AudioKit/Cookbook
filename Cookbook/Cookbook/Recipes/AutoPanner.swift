import AudioKit
import AVFoundation
import SwiftUI

struct AutoPannerData {
    var frequency: AUValue = 10.0
    var depth: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class AutoPannerConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let panner: AutoPanner
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let pannerPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        panner = AutoPanner(player)
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

    @Published var data = AutoPannerData() {
        didSet {
            panner.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            panner.$depth.ramp(to: data.depth, duration: data.rampDuration)
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

struct AutoPannerView: View {
    @ObservedObject var conductor = AutoPannerConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0.0...10.0,
                            units: "Hertz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.pannerPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("AutoPanner"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct AutoPanner_Previews: PreviewProvider {
    static var previews: some View {
        AutoPannerView()
    }
}
