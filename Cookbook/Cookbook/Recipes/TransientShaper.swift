import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct TransientShaperData {
    var inputAmount: AUValue = 0
    var attackAmount: AUValue = 0
    var releaseAmount: AUValue = 0
    var outputAmount: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class TransientShaperConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let transientshaper: TransientShaper
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        transientshaper = TransientShaper(player)
        dryWetMixer = DryWetMixer(player, transientshaper)
        engine.output = dryWetMixer
    }

    @Published var data = TransientShaperData() {
        didSet {
            transientshaper.$inputAmount.ramp(to: data.inputAmount, duration: data.rampDuration)
            transientshaper.$attackAmount.ramp(to: data.attackAmount, duration: data.rampDuration)
            transientshaper.$releaseAmount.ramp(to: data.releaseAmount, duration: data.rampDuration)
            transientshaper.$outputAmount.ramp(to: data.outputAmount, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        do { try engine.start() } catch let err {
            Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct TransientShaperView: View {
    @StateObject var conductor = TransientShaperConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Input Amount",
                            parameter: self.$conductor.data.inputAmount,
                            range: -60.0 ... 30.0,
                            units: "dB")
            ParameterSlider(text: "Attack Amount",
                            parameter: self.$conductor.data.attackAmount,
                            range: -40.0 ... 40.0,
                            units: "dB")
            ParameterSlider(text: "Release Amount",
                            parameter: self.$conductor.data.releaseAmount,
                            range: -40.0 ... 40.0,
                            units: "dB")
            ParameterSlider(text: "Output Amount",
                            parameter: self.$conductor.data.outputAmount,
                            range: -60.0 ... 30.0,
                            units: "dB")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.transientshaper, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Transient Shaper"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct TransientShaper_Previews: PreviewProvider {
    static var previews: some View {
        TransientShaperView()
    }
}
