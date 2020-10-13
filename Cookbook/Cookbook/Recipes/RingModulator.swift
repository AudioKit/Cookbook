import AudioKit
import AVFoundation
import SwiftUI

struct RingModulatorData {
    var frequency1: AUValue = 440
    var frequency2: AUValue = 660
    var mix: AUValue = 100
    var balance: AUValue = 0.5
}

class RingModulatorConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let ringModulator: RingModulator
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let ringModulatorPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        ringModulator = RingModulator(player)
        ringModulator.finalMix = 100

        dryWetMixer = DryWetMixer(player, ringModulator)
        playerPlot = NodeOutputPlot(player)
        ringModulatorPlot = NodeOutputPlot(ringModulator)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        ringModulatorPlot.plotType = .rolling
        ringModulatorPlot.color = .blue
        ringModulatorPlot.shouldFill = true
        ringModulatorPlot.shouldMirror = true
        ringModulatorPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = RingModulatorData() {
        didSet {
            ringModulator.ringModFreq1 = data.frequency1
            ringModulator.ringModFreq2 = data.frequency2
            ringModulator.finalMix = data.mix
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        ringModulatorPlot.start()
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

struct RingModulatorView: View {
    @ObservedObject var conductor = RingModulatorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency 1",
                            parameter: self.$conductor.data.frequency1,
                            range: 0.5...8000,
                            units: "Hertz")
            ParameterSlider(text: "Frequency 2",
                            parameter: self.$conductor.data.frequency2,
                            range: 0.5...8000,
                            units: "Hertz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.ringModulatorPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Ring Modulator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct RingModulator_Previews: PreviewProvider {
    static var previews: some View {
        RingModulatorView()
    }
}
