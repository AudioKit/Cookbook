import AudioKit
import AVFoundation
import SwiftUI

struct ClipperData {
    var limit: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ClipperConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let clipper: Clipper
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let clipperPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        clipper = Clipper(player)
        dryWetMixer = DryWetMixer(player, clipper)
        playerPlot = NodeOutputPlot(player)
        clipperPlot = NodeOutputPlot(clipper)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, clipperPlot, mixPlot)
    }

    @Published var data = ClipperData() {
        didSet {
            clipper.$limit.ramp(to: data.limit, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        clipperPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct ClipperView: View {
    @ObservedObject var conductor = ClipperConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Limit",
                            parameter: self.$conductor.data.limit,
                            range: 0.0...1.0,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.clipperPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Clipper"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Clipper_Previews: PreviewProvider {
    static var previews: some View {
        ClipperView()
    }
}
