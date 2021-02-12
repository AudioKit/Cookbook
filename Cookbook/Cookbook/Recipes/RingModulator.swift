import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct RingModulatorData {
    var frequency1: AUValue = 440
    var frequency2: AUValue = 660
    var mix: AUValue = 100
    var balance: AUValue = 0.5
}

class RingModulatorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let ringModulator: RingModulator
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        ringModulator = RingModulator(player)
        ringModulator.finalMix = 100

        dryWetMixer = DryWetMixer(player, ringModulator)
        engine.output = dryWetMixer
    }

    @Published var data = RingModulatorData() {
        didSet {
            ringModulator.ringModFreq1 = data.frequency1
            ringModulator.ringModFreq2 = data.frequency2
            ringModulator.finalMix = data.mix
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

struct RingModulatorView: View {
    @ObservedObject var conductor = RingModulatorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency 1",
                            parameter: self.$conductor.data.frequency1,
                            range: 0.5...8000,
                            units: "Hertz")
            ParameterSlider(text: "Frequency 2",
                            parameter: self.$conductor.data.frequency2,
                            range: 0.5...8000,
                            units: "Hertz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.ringModulator, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Ring Modulator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct RingModulator_Previews: PreviewProvider {
    static var previews: some View {
        RingModulatorView()
    }
}
