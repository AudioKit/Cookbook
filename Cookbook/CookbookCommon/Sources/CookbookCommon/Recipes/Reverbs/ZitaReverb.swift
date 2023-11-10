import AudioKit
import AudioKitEX
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
            HStack {
                ForEach(0..<6) {
                    ParameterRow(param: conductor.reverb.parameters[$0])
                }
            }
            HStack {
                ForEach(6..<10) {
                    ParameterRow(param: conductor.reverb.parameters[$0])
                }
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
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
