import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct ChowningReverbData {
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ChowningReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: ChowningReverb
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        reverb = ChowningReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        engine.output = dryWetMixer
    }

    @Published var data = ChowningReverbData() {
        didSet {
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

struct ChowningReverbView: View {
    @ObservedObject var conductor = ChowningReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.reverb, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Chowning Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ChowningReverb_Previews: PreviewProvider {
    static var previews: some View {
        ChowningReverbView()
    }
}
