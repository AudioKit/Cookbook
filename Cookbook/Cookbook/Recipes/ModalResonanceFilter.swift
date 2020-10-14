import AudioKit
import AVFoundation
import SwiftUI

struct ModalResonanceFilterData {
    var frequency: AUValue = 500.0
    var qualityFactor: AUValue = 50.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ModalResonanceFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: ModalResonanceFilter
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let filterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        filter = ModalResonanceFilter(player)
        dryWetMixer = DryWetMixer(player, filter)
        playerPlot = NodeOutputPlot(player)
        filterPlot = NodeOutputPlot(filter)
        mixPlot = NodeOutputPlot(dryWetMixer)
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

    @Published var data = ModalResonanceFilterData() {
        didSet {
            filter.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            filter.$qualityFactor.ramp(to: data.qualityFactor, duration: data.rampDuration)
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
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct ModalResonanceFilterView: View {
    @ObservedObject var conductor = ModalResonanceFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Quality Factor",
                            parameter: self.$conductor.data.qualityFactor,
                            range: 0.0...100.0,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Modal Resonance Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ModalResonanceFilter_Previews: PreviewProvider {
    static var previews: some View {
        ModalResonanceFilterView()
    }
}
