import AudioKit
import AVFoundation
import SwiftUI

struct PitchShifterData {
    var shift: AUValue = 0
    var windowSize: AUValue = 1_024
    var crossfade: AUValue = 512
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PitchShifterConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let pitchshifter: AKPitchShifter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let pitchshifterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        pitchshifter = AKPitchShifter(player)
        dryWetMixer = AKDryWetMixer(player, pitchshifter)
        playerPlot = AKNodeOutputPlot(player)
        pitchshifterPlot = AKNodeOutputPlot(pitchshifter)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        pitchshifterPlot.plotType = .rolling
        pitchshifterPlot.color = .blue
        pitchshifterPlot.shouldFill = true
        pitchshifterPlot.shouldMirror = true
        pitchshifterPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = PitchShifterData() {
        didSet {
            pitchshifter.$shift.ramp(to: data.shift, duration: data.rampDuration)
            pitchshifter.$windowSize.ramp(to: data.windowSize, duration: data.rampDuration)
            pitchshifter.$crossfade.ramp(to: data.crossfade, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        pitchshifterPlot.start()
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

struct PitchShifterView: View {
    @ObservedObject var conductor = PitchShifterConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Shift",
                            parameter: self.$conductor.data.shift,
                            range: -24.0...24.0,
                            units: "RelativeSemiTones")
            ParameterSlider(text: "Window Size",
                            parameter: self.$conductor.data.windowSize,
                            range: 0.0...10_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Crossfade",
                            parameter: self.$conductor.data.crossfade,
                            range: 0.0...10_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.pitchshifterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Pitch Shifter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PitchShifter_Previews: PreviewProvider {
    static var previews: some View {
        PitchShifterView()
    }
}
