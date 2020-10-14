import AudioKit
import AVFoundation
import SwiftUI

struct CompressorData {
    var threshold: AUValue = -20
    var headRoom: AUValue = 5
    var attackTime: AUValue = 0.001
    var releaseTime: AUValue = 0.05
    var masterGain: AUValue = 0
    var balance: AUValue = 0.5
}

class CompressorConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let compressor: Compressor
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let compressorPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        compressor = Compressor(player)

        dryWetMixer = DryWetMixer(player, compressor)
        playerPlot = NodeOutputPlot(player)
        compressorPlot = NodeOutputPlot(compressor)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, compressorPlot, mixPlot)
    }

    @Published var data = CompressorData() {
        didSet {
            compressor.threshold = data.threshold
            compressor.headRoom = data.headRoom
            compressor.attackTime = data.attackTime
            compressor.releaseTime = data.releaseTime
            compressor.masterGain = data.masterGain
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

struct CompressorView: View {
    @ObservedObject var conductor = CompressorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Threshold",
                            parameter: self.$conductor.data.threshold,
                            range: -40...20,
                            units: "dB")
            ParameterSlider(text: "Headroom",
                            parameter: self.$conductor.data.headRoom,
                            range: 0.1...40,
                            units: "dB")
            ParameterSlider(text: "Attack Duration",
                            parameter: self.$conductor.data.attackTime,
                            range: 0.001...0.2,
                            units: "Seconds")
            ParameterSlider(text: "Release Duration",
                            parameter: self.$conductor.data.releaseTime,
                            range: 0.01...3,
                            units: "Seconds")
            ParameterSlider(text: "Master Gain",
                            parameter: self.$conductor.data.masterGain,
                            range: -40...40,
                            units: "dB")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.compressorPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Compressor"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Compressor_Previews: PreviewProvider {
    static var previews: some View {
        CompressorView()
    }
}
