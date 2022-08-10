import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct BitCrusherData {
    var bitDepth: AUValue = 8
    var sampleRate: AUValue = 10000
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class BitCrusherConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let bitcrusher: BitCrusher
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        bitcrusher = BitCrusher(player)
        dryWetMixer = DryWetMixer(player, bitcrusher)
        engine.output = dryWetMixer
    }

    @Published var data = BitCrusherData() {
        didSet {
            bitcrusher.$bitDepth.ramp(to: data.bitDepth, duration: data.rampDuration)
            bitcrusher.$sampleRate.ramp(to: data.sampleRate, duration: data.rampDuration)
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

struct BitCrusherView: View {
    @StateObject var conductor = BitCrusherConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Bit Depth",
                            parameter: self.$conductor.data.bitDepth,
                            range: 1 ... 24,
                            units: "Generic")
            ParameterSlider(text: "Sample Rate",
                            parameter: self.$conductor.data.sampleRate,
                            range: 0.0 ... 20000.0,
                            units: "Hertz")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.bitcrusher, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Bit Crusher")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct BitCrusher_Previews: PreviewProvider {
    static var previews: some View {
        BitCrusherView()
    }
}
