import AudioKit
import AVFoundation
import SwiftUI

struct VariableDelayData {
    var time: AUValue = 0
    var feedback: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class VariableDelayConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let delay: VariableDelay
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let delayPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        delay = VariableDelay(player)
        dryWetMixer = DryWetMixer(player, delay)
        playerPlot = NodeOutputPlot(player)
        delayPlot = NodeOutputPlot(delay)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        delayPlot.plotType = .rolling
        delayPlot.color = .blue
        delayPlot.shouldFill = true
        delayPlot.shouldMirror = true
        delayPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = VariableDelayData() {
        didSet {
            delay.$time.ramp(to: data.time, duration: data.rampDuration)
            delay.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        delayPlot.start()
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

struct VariableDelayView: View {
    @ObservedObject var conductor = VariableDelayConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Time",
                            parameter: self.$conductor.data.time,
                            range: 0...10,
                            units: "Seconds")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0...1,
                            units: "Generic")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.delayPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Variable Delay"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct VariableDelay_Previews: PreviewProvider {
    static var previews: some View {
        VariableDelayView()
    }
}
