import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

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
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.panner.parameters) {
                    ParameterEditor2(param: $0)
                }
                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.panner,
                          mix: conductor.dryWetMixer)
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
