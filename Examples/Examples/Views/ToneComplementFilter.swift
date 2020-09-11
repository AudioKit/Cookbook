import AudioKit
import AVFoundation
import SwiftUI

struct ToneComplementFilterData {
    var halfPowerPoint: AUValue = 1_000.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ToneComplementFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKToneComplementFilter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKToneComplementFilter(player)
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

    @Published var data = ToneComplementFilterData() {
        didSet {
            filter.$halfPowerPoint.ramp(to: data.halfPowerPoint, duration: data.rampDuration)
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

struct ToneComplementFilterView: View {
    @ObservedObject var conductor = ToneComplementFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Half Power Point",
                            parameter: self.$conductor.data.halfPowerPoint,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Tone Complement Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ToneComplementFilter_Previews: PreviewProvider {
    static var previews: some View {
        ToneComplementFilterView()
    }
}
