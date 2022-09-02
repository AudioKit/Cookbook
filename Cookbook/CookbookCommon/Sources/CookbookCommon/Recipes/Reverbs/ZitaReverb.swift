import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class ZitaReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: ZitaReverb
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.module.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        do {
            let file = try AVAudioFile(forReading: url!)
            buffer = try AVAudioPCMBuffer(file: file)!
        } catch {
            fatalError()
        }
        reverb = ZitaReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)

        engine.output = dryWetMixer
    }
}

struct ZitaReverbView: View {
    @StateObject var conductor = ZitaReverbConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(0..<6) {
                    ParameterEditor2(param: conductor.reverb.parameters[$0])
                }
            }
            HStack(spacing: 50) {
                ForEach(6..<10) {
                    ParameterEditor2(param: conductor.reverb.parameters[$0])
                }

                ParameterEditor2(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.reverb,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Zita Reverb")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
