import AudioKit
import AVFoundation
import SwiftUI

struct ChowningReverbData {
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ChowningReverbConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: ChowningReverb
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let reverbPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        reverb = ChowningReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        playerPlot = NodeOutputPlot(player)
        reverbPlot = NodeOutputPlot(reverb)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        reverbPlot.plotType = .rolling
        reverbPlot.color = .blue
        reverbPlot.shouldFill = true
        reverbPlot.shouldMirror = true
        reverbPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = ChowningReverbData() {
        didSet {
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        reverbPlot.start()
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

struct ChowningReverbView: View {
    @ObservedObject var conductor = ChowningReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.reverbPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Chowning Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ChowningReverb_Previews: PreviewProvider {
    static var previews: some View {
        ChowningReverbView()
    }
}
