import AudioKit
import AVFoundation
import SwiftUI

struct LowShelfFilterData {
    var cutoffFrequency: AUValue = 80
    var gain: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class LowShelfFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: LowShelfFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeFFTPlot
    let filterPlot: NodeFFTPlot
    let mixPlot: NodeFFTPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        filter = LowShelfFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        playerPlot = NodeFFTPlot(player)
        filterPlot = NodeFFTPlot(filter)
        mixPlot = NodeFFTPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        filterPlot.plotType = .rolling
        filterPlot.color = .blue
        filterPlot.shouldFill = true
        filterPlot.shouldMirror = true
        filterPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = LowShelfFilterData() {
        didSet {
            filter.cutoffFrequency = data.cutoffFrequency
            filter.gain = data.gain
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
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

struct LowShelfFilterView: View {
    @ObservedObject var conductor = LowShelfFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...200.0,
                            units: "Hertz")
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: -40...40,
                            units: "dB")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixFFTPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Low Shelf Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct LowShelfFilter_Previews: PreviewProvider {
    static var previews: some View {
        LowShelfFilterView()
    }
}
