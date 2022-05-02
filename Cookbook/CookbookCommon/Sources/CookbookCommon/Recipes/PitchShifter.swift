import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct PitchShifterData {
    var shift: AUValue = 0
    var windowSize: AUValue = 1_024
    var crossfade: AUValue = 512
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PitchShifterConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let pitchshifter: PitchShifter
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        pitchshifter = PitchShifter(player)
        dryWetMixer = DryWetMixer(player, pitchshifter)
        engine.output = dryWetMixer
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
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct PitchShifterView: View {
    @StateObject var conductor = PitchShifterConductor()

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
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.pitchshifter, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Pitch Shifter")
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
