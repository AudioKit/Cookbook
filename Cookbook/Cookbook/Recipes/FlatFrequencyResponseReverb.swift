import AudioKit
import AVFoundation
import SwiftUI

struct FlatFrequencyResponseReverbData {
    var reverbDuration: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class FlatFrequencyResponseReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer2()
    let reverb: FlatFrequencyResponseReverb
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let reverbPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        reverb = FlatFrequencyResponseReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        playerPlot = NodeOutputPlot(player)
        reverbPlot = NodeOutputPlot(reverb)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, reverbPlot, mixPlot)
    }

    @Published var data = FlatFrequencyResponseReverbData() {
        didSet {
            reverb.$reverbDuration.ramp(to: data.reverbDuration, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        reverbPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct FlatFrequencyResponseReverbView: View {
    @ObservedObject var conductor = FlatFrequencyResponseReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Reverb Duration",
                            parameter: self.$conductor.data.reverbDuration,
                            range: 0...10,
                            units: "Seconds")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.reverbPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Flat Frequency Response Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct FlatFrequencyResponseReverb_Previews: PreviewProvider {
    static var previews: some View {
        FlatFrequencyResponseReverbView()
    }
}
