import AudioKit
import AVFoundation
import SwiftUI

struct VariableDelayOperationData {
    var maxTime: AUValue = 0.2
    var frequency: AUValue = 0.3
    var feedbackFrequency: AUValue = 0.21
    var rampDuration: AUValue = 0.1
    var balance: AUValue = 0.5
}

class VariableDelayOperationConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let delayPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer
    let delay: OperationEffect


    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        delay = OperationEffect(player) { player, parameters in
            let time = Operation.sineWave(frequency: parameters[1])
                .scale(minimum: 0.001, maximum: parameters[0])
            let feedback = Operation.sineWave(frequency: parameters[2])
                .scale(minimum: 0.5, maximum: 0.9)
            return player.variableDelay(time: time,
                                        feedback: feedback,
                                        maximumDelayTime: 1.0)
        }
        delay.parameter1 = 0.2
        delay.parameter2 = 0.3
        delay.parameter3 = 0.21

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

    @Published var data = VariableDelayOperationData() {
        didSet {
            delay.$parameter1.ramp(to: data.maxTime, duration: data.rampDuration)
            delay.$parameter2.ramp(to: data.frequency, duration: data.rampDuration)
            delay.$parameter3.ramp(to: data.feedbackFrequency, duration: data.rampDuration)
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

struct VariableDelayOperationView: View {
    @ObservedObject var conductor = VariableDelayOperationConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Max Time",
                            parameter: self.$conductor.data.maxTime,
                            range: 0...0.3,
                            units: "Seconds")
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0...1,
                            units: "Hz")
            ParameterSlider(text: "Feedback Frequency",
                            parameter: self.$conductor.data.feedbackFrequency,
                            range: 0...1,
                            units: "Hz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.delayPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Variable Delay Fun"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct VariableDelayOperation_Previews: PreviewProvider {
    static var previews: some View {
        VariableDelayOperationView()
    }
}
