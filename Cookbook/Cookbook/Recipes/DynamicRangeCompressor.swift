import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct DynamicRangeCompressorData {
    var ratio: AUValue = 1
    var threshold: AUValue = 0.0
    var attackDuration: AUValue = 0.1
    var releaseDuration: AUValue = 0.1
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class DynamicRangeCompressorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let compressor: DynamicRangeCompressor
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        compressor = DynamicRangeCompressor(player)
        dryWetMixer = DryWetMixer(player, compressor)
        engine.output = dryWetMixer
    }

    @Published var data = DynamicRangeCompressorData() {
        didSet {
            compressor.$ratio.ramp(to: data.ratio, duration: data.rampDuration)
            compressor.$threshold.ramp(to: data.threshold, duration: data.rampDuration)
            compressor.$attackDuration.ramp(to: data.attackDuration, duration: data.rampDuration)
            compressor.$releaseDuration.ramp(to: data.releaseDuration, duration: data.rampDuration)
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

struct DynamicRangeCompressorView: View {
    @StateObject var conductor = DynamicRangeCompressorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Ratio",
                            parameter: self.$conductor.data.ratio,
                            range: 0.01...100.0,
                            units: "Hertz")
            ParameterSlider(text: "Threshold",
                            parameter: self.$conductor.data.threshold,
                            range: -100.0...0.0,
                            units: "Generic")
            ParameterSlider(text: "Attack Duration",
                            parameter: self.$conductor.data.attackDuration,
                            range: 0.0...1.0,
                            units: "Seconds")
            ParameterSlider(text: "Release Duration",
                            parameter: self.$conductor.data.releaseDuration,
                            range: 0.0...1.0,
                            units: "Seconds")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.compressor, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Dynamic Range Compressor"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct DynamicRangeCompressor_Previews: PreviewProvider {
    static var previews: some View {
        DynamicRangeCompressorView()
    }
}
