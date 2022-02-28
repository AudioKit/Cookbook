import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct PannerData {
    var pan: AUValue = 0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class PannerConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let panner: Panner
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        panner = Panner(player)
        dryWetMixer = DryWetMixer(player, panner)
        engine.output = dryWetMixer
    }

    @Published var data = PannerData() {
        didSet {
            panner.$pan.ramp(to: data.pan, duration: data.rampDuration)
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

struct PannerView: View {
    @StateObject var conductor = PannerConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Pan",
                            parameter: self.$conductor.data.pan,
                            range: -1...1,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.panner, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Panner")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Panner_Previews: PreviewProvider {
    static var previews: some View {
        PannerView()
    }
}
