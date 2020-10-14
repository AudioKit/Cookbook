import AudioKit
import AVFoundation
import SwiftUI

struct EqualizerFilterData {
    var centerFrequency: AUValue = 1_000.0
    var bandwidth: AUValue = 100.0
    var gain: AUValue = 10.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class EqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: EqualizerFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let filterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        filter = EqualizerFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        playerPlot = NodeOutputPlot(player)
        filterPlot = NodeOutputPlot(filter)
        mixPlot = NodeOutputPlot(dryWetMixer)
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

    @Published var data = EqualizerFilterData() {
        didSet {
            filter.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            filter.$bandwidth.ramp(to: data.bandwidth, duration: data.rampDuration)
            filter.$gain.ramp(to: data.gain, duration: data.rampDuration)
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

struct EqualizerFilterView: View {
    @ObservedObject var conductor = EqualizerFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Center Frequency",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Bandwidth",
                            parameter: self.$conductor.data.bandwidth,
                            range: 0.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: -100.0...100.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Equalizer Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct EqualizerFilter_Previews: PreviewProvider {
    static var previews: some View {
        EqualizerFilterView()
    }
}
