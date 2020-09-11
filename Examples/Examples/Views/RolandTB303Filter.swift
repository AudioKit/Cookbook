import AudioKit
import AVFoundation
import SwiftUI

struct RolandTB303FilterData {
    var cutoffFrequency: AUValue = 500
    var resonance: AUValue = 0.5
    var distortion: AUValue = 2.0
    var resonanceAsymmetry: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class RolandTB303FilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKRolandTB303Filter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKRolandTB303Filter(player)
        dryWetMixer = AKDryWetMixer(player, filter)
        playerPlot = AKNodeOutputPlot(player)
        filterPlot = AKNodeOutputPlot(filter)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
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

    @Published var data = RolandTB303FilterData() {
        didSet {
            filter.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
            filter.$resonance.ramp(to: data.resonance, duration: data.rampDuration)
            filter.$distortion.ramp(to: data.distortion, duration: data.rampDuration)
            filter.$resonanceAsymmetry.ramp(to: data.resonanceAsymmetry, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
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

struct RolandTB303FilterView: View {
    @ObservedObject var conductor = RolandTB303FilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Resonance",
                            parameter: self.$conductor.data.resonance,
                            range: 0.0...2.0,
                            units: "Generic")
            ParameterSlider(text: "Distortion",
                            parameter: self.$conductor.data.distortion,
                            range: 0.0...4.0,
                            units: "Generic")
            ParameterSlider(text: "Resonance Asymmetry",
                            parameter: self.$conductor.data.resonanceAsymmetry,
                            range: 0.0...1.0,
                            units: "Generic")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Roland Tb303 Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct RolandTB303Filter_Previews: PreviewProvider {
    static var previews: some View {
        RolandTB303FilterView()
    }
}
