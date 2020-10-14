import AudioKit
import AVFoundation
import SwiftUI

struct DynamicRangeCompressorData {
    var ratio: AUValue = 1
    var threshold: AUValue = 0.0
    var attackDuration: AUValue = 0.1
    var releaseDuration: AUValue = 0.1
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class DynamicRangeCompressorConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let compressor: DynamicRangeCompressor
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let compressorPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        compressor = DynamicRangeCompressor(player)
        dryWetMixer = DryWetMixer(player, compressor)
        playerPlot = NodeOutputPlot(player)
        compressorPlot = NodeOutputPlot(compressor)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        compressorPlot.plotType = .rolling
        compressorPlot.color = .blue
        compressorPlot.shouldFill = true
        compressorPlot.shouldMirror = true
        compressorPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = DynamicRangeCompressorData() {
        didSet {
            compressor.$ratio.ramp(to: data.ratio, duration: data.rampDuration)
            compressor.$threshold.ramp(to: data.threshold, duration: data.rampDuration)
            compressor.$attackDuration.ramp(to: data.attackDuration, duration: data.rampDuration)
            compressor.$releaseDuration.ramp(to: data.releaseDuration, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        compressorPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct DynamicRangeCompressorView: View {
    @ObservedObject var conductor = DynamicRangeCompressorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Ratio",
                            parameter: self.$conductor.data.ratio,
                            range: 0.01...100.0,
                            units: "Hertz")
            ParameterSlider(text: "Threshold",
                            parameter: self.$conductor.data.threshold,
                            range: -100.0...0.0,
                            units: "Generic")
            ParameterSlider(text: "Attack Duration",
                            parameter: self.$conductor.data.attackDuration,
                            range: 0.0...1.0,
                            units: "Seconds")
            ParameterSlider(text: "Release Duration",
                            parameter: self.$conductor.data.releaseDuration,
                            range: 0.0...1.0,
                            units: "Seconds")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.compressorPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Dynamic Range Compressor"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct DynamicRangeCompressor_Previews: PreviewProvider {
    static var previews: some View {
        DynamicRangeCompressorView()
    }
}
