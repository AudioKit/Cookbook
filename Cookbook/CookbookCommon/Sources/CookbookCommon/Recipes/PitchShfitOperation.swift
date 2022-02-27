import AudioKit
import AudioKitUI
import AVFoundation
import SporthAudioKit
import SoundpipeAudioKit
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
    let player = AudioPlayer()
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer
    let pitchShift: OperationEffect

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        pitchShift = OperationEffect(player) { player, parameters in
            let sinusoid = Operation.sineWave(frequency: parameters[2])
            let shift = parameters[0] + sinusoid * parameters[1] / 2.0
            return player.pitchShift(semitones: shift)
        }
        pitchShift.parameter1 = 0
        pitchShift.parameter2 = 7
        pitchShift.parameter3 = 3

        dryWetMixer = DryWetMixer(player, pitchShift)
        engine.output = dryWetMixer
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
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct PitchShiftOperationView: View {
    @StateObject var conductor = PitchShiftOperationConductor()

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
            DryWetMixView(dry: conductor.player, wet: conductor.pitchShift, mix: conductor.dryWetMixer)
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
