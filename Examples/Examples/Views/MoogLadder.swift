import AudioKit
import AVFoundation
import SwiftUI

//: One of the coolest filters available in AudioKit is the Moog Ladder.
//: It's based off of Robert Moog's iconic ladder filter, which was the
//: first implementation of a voltage - controlled filter used in an
//: analog synthesizer. As such, it was the first filter that gave the
//: ability to use voltage control to determine the cutoff frequency of the
//: filter. As we're dealing with a software implementation, and not an
//: analog synthesizer, we don't have to worry about dealing with
//: voltage control directly. However, by using this node, you can
//: emulate some of the sounds of classic analog synthesizers in your app.

struct MoogLadderData {
    var cutoffFrequency: AUValue = 1_000
    var resonance: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class MoogLadderConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let filter: MoogLadder
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let filterPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = MoogLadder(player)
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

    @Published var data = MoogLadderData() {
        didSet {
            filter.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
            filter.$resonance.ramp(to: data.resonance, duration: data.rampDuration)
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

struct MoogLadderView: View {
    @ObservedObject var conductor = MoogLadderConductor()

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
                            units: "Percent")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Moog Ladder"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct MoogLadder_Previews: PreviewProvider {
    static var previews: some View {
        MoogLadderView()
    }
}
