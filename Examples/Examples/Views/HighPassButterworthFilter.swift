import AudioKit
import AVFoundation
import SwiftUI

//: A high-pass filter takes an audio signal as an input, and cuts out the
//: low-frequency components of the audio signal, allowing for the higher frequency
//: components to "pass through" the filter.

struct HighPassButterworthFilterData {
    var cutoffFrequency: AUValue = 500.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class HighPassButterworthFilterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKHighPassButterworthFilter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKHighPassButterworthFilter(player)
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

    @Published var data = HighPassButterworthFilterData() {
        didSet {
            filter.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
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

struct HighPassButterworthFilterView: View {
    @ObservedObject var conductor = HighPassButterworthFilterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...20_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("High Pass Butterworth Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct HighPassButterworthFilter_Previews: PreviewProvider {
    static var previews: some View {
        HighPassButterworthFilterView()
    }
}
