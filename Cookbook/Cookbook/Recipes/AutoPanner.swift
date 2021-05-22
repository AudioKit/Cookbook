import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct AutoPannerData {
    var frequency: AUValue = 10.0
    var depth: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class AutoPannerConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let panner: AutoPanner
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        panner = AutoPanner(player)
        dryWetMixer = DryWetMixer(player, panner)
        engine.output = dryWetMixer
    }

    @Published var data = AutoPannerData() {
        didSet {
            panner.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            panner.$depth.ramp(to: data.depth, duration: data.rampDuration)
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

struct AutoPannerView: View {
    @StateObject var conductor = AutoPannerConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0.0...10.0,
                            units: "Hertz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.panner, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Auto Panner"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct AutoPanner_Previews: PreviewProvider {
    static var previews: some View {
        AutoPannerView()
    }
}
