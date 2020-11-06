import AudioKit
import AVFoundation
import SwiftUI

struct PhaserData {
    var notchMinimumFrequency: AUValue = 100
    var notchMaximumFrequency: AUValue = 800
    var notchWidth: AUValue = 1_000
    var notchFrequency: AUValue = 1.5
    var vibratoMode: AUValue = 1
    var depth: AUValue = 1
    var feedback: AUValue = 0
    var inverted: AUValue = 0
    var lfoBPM: AUValue = 30
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PhaserConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer2()
    let phaser: Phaser
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let phaserPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        phaser = Phaser(player)
        dryWetMixer = DryWetMixer(player, phaser)
        playerPlot = NodeOutputPlot(player)
        phaserPlot = NodeOutputPlot(phaser)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, phaserPlot, mixPlot)
    }

    @Published var data = PhaserData() {
        didSet {
            phaser.$notchMinimumFrequency.ramp(to: data.notchMinimumFrequency, duration: data.rampDuration)
            phaser.$notchMaximumFrequency.ramp(to: data.notchMaximumFrequency, duration: data.rampDuration)
            phaser.$notchWidth.ramp(to: data.notchWidth, duration: data.rampDuration)
            phaser.$notchFrequency.ramp(to: data.notchFrequency, duration: data.rampDuration)
            phaser.$vibratoMode.ramp(to: data.vibratoMode, duration: data.rampDuration)
            phaser.$depth.ramp(to: data.depth, duration: data.rampDuration)
            phaser.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
            phaser.$inverted.ramp(to: data.inverted, duration: data.rampDuration)
            phaser.$lfoBPM.ramp(to: data.lfoBPM, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        phaserPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct PhaserView: View {
    @ObservedObject var conductor = PhaserConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            VStack {
            ParameterSlider(text: "Notch Minimum Frequency",
                            parameter: self.$conductor.data.notchMinimumFrequency,
                            range: 20...5_000,
                            units: "Hertz")
            ParameterSlider(text: "Notch Maximum Frequency",
                            parameter: self.$conductor.data.notchMaximumFrequency,
                            range: 20...10_000,
                            units: "Hertz")
            ParameterSlider(text: "Notch Width",
                            parameter: self.$conductor.data.notchWidth,
                            range: 10...5_000,
                            units: "Hertz")
            ParameterSlider(text: "Notch Frequency",
                            parameter: self.$conductor.data.notchFrequency,
                            range: 1.1...4.0,
                            units: "Hertz")
            ParameterSlider(text: "Vibrato Mode",
                            parameter: self.$conductor.data.vibratoMode,
                            range: 0...1,
                            units: "Generic")
            }
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0...1,
                            units: "Generic")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0...1,
                            units: "Generic")
            ParameterSlider(text: "Inverted",
                            parameter: self.$conductor.data.inverted,
                            range: 0...1,
                            units: "Generic")
            ParameterSlider(text: "Lfo Bpm",
                            parameter: self.$conductor.data.lfoBPM,
                            range: 24...360,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.phaserPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Phaser"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Phaser_Previews: PreviewProvider {
    static var previews: some View {
        PhaserView()
    }
}
