import AudioKit
import AVFoundation
import SwiftUI

struct PeakingParametricEqualizerFilterData {
    var centerFrequency: AUValue = 1_000
    var gain: AUValue = 1.0
    var q: AUValue = 0.707
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PeakingParametricEqualizerFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let equalizer: AKPeakingParametricEqualizerFilter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let equalizerPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        equalizer = AKPeakingParametricEqualizerFilter(player)
        dryWetMixer = AKDryWetMixer(player, equalizer)
        playerPlot = AKNodeOutputPlot(player)
        equalizerPlot = AKNodeOutputPlot(equalizer)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        equalizerPlot.plotType = .rolling
        equalizerPlot.color = .blue
        equalizerPlot.shouldFill = true
        equalizerPlot.shouldMirror = true
        equalizerPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = PeakingParametricEqualizerFilterData() {
        didSet {
            equalizer.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
            equalizer.$gain.ramp(to: data.gain, duration: data.rampDuration)
            equalizer.$q.ramp(to: data.q, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        equalizerPlot.start()
        mixPlot.start()

        do {
            try engine.start()
            // player stuff has to be done after start
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct PeakingParametricEqualizerFilterView: View {
    @ObservedObject var conductor = PeakingParametricEqualizerFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Center Frequency",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: 0.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Q",
                            parameter: self.$conductor.data.q,
                            range: 0.0...2.0,
                            units: "Generic")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.equalizerPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Peaking Parametric Equalizer Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PeakingParametricEqualizerFilter_Previews: PreviewProvider {
    static var previews: some View {
        PeakingParametricEqualizerFilterView()
    }
}
