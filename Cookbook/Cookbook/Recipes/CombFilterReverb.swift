import AudioKit
import AVFoundation
import SwiftUI

struct CombFilterReverbData {
    var reverbDuration: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class CombFilterReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: CombFilterReverb
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let filterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filter = CombFilterReverb(player)
        dryWetMixer = DryWetMixer(player, filter)
        playerPlot = NodeOutputPlot(player)
        filterPlot = NodeOutputPlot(filter)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, filterPlot, mixPlot)
    }

    @Published var data = CombFilterReverbData() {
        didSet {
            filter.$reverbDuration.ramp(to: data.reverbDuration, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct CombFilterReverbView: View {
    @ObservedObject var conductor = CombFilterReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Reverb Duration",
                            parameter: self.$conductor.data.reverbDuration,
                            range: 0.0...10.0,
                            units: "Seconds")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Comb Filter Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct CombFilterReverb_Previews: PreviewProvider {
    static var previews: some View {
        CombFilterReverbView()
    }
}
