import AudioKit
import AVFoundation
import SwiftUI

struct PitchShiftOperationData {
    var baseShift: AUValue = 0
    var range: AUValue = 7
    var speed: AUValue = 3
    var rampDuration: AUValue = 0.1
    var balance: AUValue = 0.5
}

class PitchShiftOperationConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer2()
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let pitchShiftPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer
    let pitchShift: OperationEffect


    init() {
        buffer = Cookbook.sourceBuffer

        pitchShift = OperationEffect(player) { player, parameters in
            let sinusoid = Operation.sineWave(frequency: parameters[2])
            let shift = parameters[0] + sinusoid * parameters[1] / 2.0
            return player.pitchShift(semitones: shift)
        }
        pitchShift.parameter1 = 0
        pitchShift.parameter2 = 7
        pitchShift.parameter3 = 3

        dryWetMixer = DryWetMixer(player, pitchShift)
        playerPlot = NodeOutputPlot(player)
        pitchShiftPlot = NodeOutputPlot(pitchShift)
        mixPlot = NodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        Cookbook.setupDryWetMixPlots(playerPlot, pitchShiftPlot, mixPlot)
    }

    @Published var data = PitchShiftOperationData() {
        didSet {
            pitchShift.$parameter1.ramp(to: data.baseShift, duration: data.rampDuration)
            pitchShift.$parameter2.ramp(to: data.range, duration: data.rampDuration)
            pitchShift.$parameter3.ramp(to: data.speed, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        pitchShiftPlot.start()
        mixPlot.start()

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct PitchShiftOperationView: View {
    @ObservedObject var conductor = PitchShiftOperationConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Base Shift",
                            parameter: self.$conductor.data.baseShift,
                            range: -12...12,
                            units: "Semitones")
            ParameterSlider(text: "Range",
                            parameter: self.$conductor.data.range,
                            range: 0...24,
                            units: "Semitones")
            ParameterSlider(text: "Speed",
                            parameter: self.$conductor.data.speed,
                            range: 0.001...10,
                            units: "Hz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.pitchShiftPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Pitch Shift Fun"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PitchShiftOperation_Previews: PreviewProvider {
    static var previews: some View {
        PitchShiftOperationView()
    }
}
