import AudioKit
import AVFoundation
import SwiftUI

struct ChorusData {
    var frequency: AUValue = 1.0
    var depth: AUValue = 1.0
    var feedback: AUValue = 0.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ChorusConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let chorus: Chorus
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let chorusPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        chorus = Chorus(player)
        dryWetMixer = DryWetMixer(player, chorus)
        playerPlot = NodeOutputPlot(player)
        chorusPlot = NodeOutputPlot(chorus)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .buffer
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        chorusPlot.plotType = .rolling
        chorusPlot.color = .blue
        chorusPlot.shouldFill = true
        chorusPlot.shouldMirror = true
        chorusPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = ChorusData() {
        didSet {
            chorus.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            chorus.$depth.ramp(to: data.depth, duration: data.rampDuration)
            chorus.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        chorusPlot.start()
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

struct ChorusView: View {
    @ObservedObject var conductor = ChorusConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0.1...10.0,
                            units: "Hz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "%")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: -0.95 ... 0.95,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.chorusPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Chorus"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Chorus_Previews: PreviewProvider {
    static var previews: some View {
        ChorusView()
    }
}
