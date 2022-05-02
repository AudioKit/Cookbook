import AudioKit
import AudioKitEX
import SoundpipeAudioKit
import AudioKitUI

import AVFoundation
import SwiftUI

struct ClipperData {
    var limit: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ClipperConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let clipper: Clipper
    let amplifier: Fader
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        clipper = Clipper(player)
        amplifier = Fader(clipper)
        dryWetMixer = DryWetMixer(player, amplifier)
        engine.output = dryWetMixer
    }

    @Published var data = ClipperData() {
        didSet {
            clipper.$limit.ramp(to: data.limit, duration: data.rampDuration)
            if data.limit > 0.25 {
                amplifier.gain = 1.0 / data.limit
            }
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

struct ClipperView: View {
    @StateObject var conductor = ClipperConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Limit",
                            parameter: self.$conductor.data.limit,
                            range: 0.0...1.0,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")

            DryWetMixView(dry: conductor.player, wet: conductor.clipper, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Clipper")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Clipper_Previews: PreviewProvider {
    static var previews: some View {
        ClipperView()
    }
}
