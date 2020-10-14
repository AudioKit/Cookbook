import AudioKit
import AVFoundation
import SwiftUI

struct HighPassFilterData {
    var cutoffFrequency: AUValue = 1_000
    var resonance: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class HighPassFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: HighPassFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeFFTPlot
    let filterPlot: NodeFFTPlot
    let mixPlot: NodeFFTPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        filter = HighPassFilter(player)
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

    @Published var data = HighPassFilterData() {
        didSet {
            filter.cutoffFrequency = data.cutoffFrequency
            filter.resonance = data.resonance
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct HighPassFilterView: View {
    @ObservedObject var conductor = HighPassFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...3_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Resonance",
                            parameter: self.$conductor.data.resonance,
                            range: -20...40,
                            units: "dB")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixFFTPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("High Pass Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct HighPassFilter_Previews: PreviewProvider {
    static var previews: some View {
        HighPassFilterView()
    }
}
