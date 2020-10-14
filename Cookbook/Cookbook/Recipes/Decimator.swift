import AudioKit
import AVFoundation
import SwiftUI

//: Decimation is a type of digital distortion like bit crushing,
//: but instead of directly stating what bit depth and sample rate you want,
//: it is done through setting "decimation" and "rounding" parameters.

struct DecimatorData {
    var decimation: AUValue = 50
    var rounding: AUValue = 50
    var mix: AUValue = 100
    var balance: AUValue = 0.5
}

class DecimatorConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let decimator: Decimator
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let decimatorPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        decimator = Decimator(player)
        decimator.finalMix = 100

        dryWetMixer = DryWetMixer(player, decimator)
        playerPlot = NodeOutputPlot(player)
        decimatorPlot = NodeOutputPlot(decimator)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        decimatorPlot.plotType = .rolling
        decimatorPlot.color = .blue
        decimatorPlot.shouldFill = true
        decimatorPlot.shouldMirror = true
        decimatorPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = DecimatorData() {
        didSet {
            decimator.decimation = data.decimation
            decimator.rounding = data.rounding
            decimator.finalMix = data.mix
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        decimatorPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct DecimatorView: View {
    @ObservedObject var conductor = DecimatorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Decimation",
                            parameter: self.$conductor.data.decimation,
                            range: 0...100,
                            units: "Percent-0-100")
            ParameterSlider(text: "Rounding",
                            parameter: self.$conductor.data.rounding,
                            range: 0...100,
                            units: "Percent-0-100")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.decimatorPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Decimator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Decimator_Previews: PreviewProvider {
    static var previews: some View {
        DecimatorView()
    }
}
