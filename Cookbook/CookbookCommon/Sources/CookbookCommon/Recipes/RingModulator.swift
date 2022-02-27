import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct RingModulatorData {
    var frequency1: AUValue = 440
    var frequency2: AUValue = 660
    var mix: AUValue = 50
    var balance: AUValue = 50
}

class RingModulatorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let ringModulator: RingModulator
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        ringModulator = RingModulator(player)

        engine.output = ringModulator
    }

    @Published var data = RingModulatorData() {
        didSet {
            ringModulator.ringModFreq1 = data.frequency1
            ringModulator.ringModFreq2 = data.frequency2
            ringModulator.ringModBalance = data.balance
            ringModulator.finalMix = data.mix
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
    @StateObject var conductor = RingModulatorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency 1",
                            parameter: self.$conductor.data.frequency1,
                            range: 0.5...2000,
                            units: "Hertz")
            ParameterSlider(text: "Frequency 2",
                            parameter: self.$conductor.data.frequency2,
                            range: 0.5...2000,
                            units: "Hertz")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...100,
                            units: "Percent-0-100")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.mix,
                            range: 0...100,
                            units: "Percent-0-100")
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
