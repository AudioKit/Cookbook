import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct AutoPannerData {
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
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.panner.parameters) {
                    ParameterEditor2(param: $0)
                }
            }
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.panner, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Auto Panner")
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
