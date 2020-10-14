import AudioKit
import AVFoundation
import SwiftUI

//: A peak limiter will set a hard limit on the amplitude of an audio signal.
//: They're espeically useful for any type of live input processing, when you
//: may not be in total control of the audio signal you're recording or processing.

struct PeakLimiterData {
    var attackTime: AUValue = 0.012
    var decayTime: AUValue = 0.024
    var preGain: AUValue = 0
    var balance: AUValue = 0.5
}

class PeakLimiterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let peakLimiter: PeakLimiter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let peakLimiterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        peakLimiter = PeakLimiter(player)

        dryWetMixer = DryWetMixer(player, peakLimiter)
        playerPlot = NodeOutputPlot(player)
        peakLimiterPlot = NodeOutputPlot(peakLimiter)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, peakLimiterPlot, mixPlot)
    }

    @Published var data = PeakLimiterData() {
        didSet {
            peakLimiter.attackTime = data.attackTime
            peakLimiter.decayTime = data.decayTime
            peakLimiter.preGain = data.preGain
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        peakLimiterPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct PeakLimiterView: View {
    @ObservedObject var conductor = PeakLimiterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Attack Duration",
                            parameter: self.$conductor.data.attackTime,
                            range: 0.001...0.03,
                            units: "Seconds")
            ParameterSlider(text: "Decay Duration",
                            parameter: self.$conductor.data.decayTime,
                            range: 0.001...0.03,
                            units: "Seconds")
            ParameterSlider(text: "Pre-Gain",
                            parameter: self.$conductor.data.preGain,
                            range: -40...40,
                            units: "dB")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.peakLimiterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("PeakLimiter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PeakLimiter_Previews: PreviewProvider {
    static var previews: some View {
        PeakLimiterView()
    }
}
