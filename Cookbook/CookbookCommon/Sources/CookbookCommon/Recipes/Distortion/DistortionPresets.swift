import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

// It's very common to mix exactly two inputs, one before processing occurs,
// and one after, resulting in a combination of the two.  This is so common
// that many of the AudioKit nodes have a dry/wet mix parameter built in.
//  But, if you are building your own custom effects, or making a long chain
// of effects, you can use DryWetMixer to blend your signals.

class DistortionConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let distortion: AppleDistortion
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer
    @Published var preGain : Float = -6.0 {
        didSet {
            distortion.preGain = preGain
        }
    }

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        distortion = AppleDistortion(player)
        distortion.loadFactoryPreset(.multiDistortedCubed)

        // We're not using distortion's built in dry wet mix because
        // we are tapping the wet result so it can be plotted.
        distortion.dryWetMix = 100
        dryWetMixer = DryWetMixer(player, distortion)
        engine.output = dryWetMixer
    }
}

struct DistortionView: View {
    @StateObject var conductor = DistortionConductor()
    @State var currentPreset = 0
    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                Button(action: {
                    currentPreset = currentPreset-1 < 0 ? 21 : currentPreset-1
                    conductor.distortion.loadFactoryPreset(
                        AVAudioUnitDistortionPreset(rawValue: currentPreset) ?? .drumsBitBrush)
                    
                }) {
                    Image(systemName: "arrowtriangle.backward.fill").foregroundColor(.blue)
                }
                Text(AVAudioUnitDistortionPreset(rawValue: currentPreset)!.name).frame(minWidth: 200)
                Button(action: {
                    currentPreset = (currentPreset + 1) % 22
                    conductor.distortion.loadFactoryPreset(
                        AVAudioUnitDistortionPreset(rawValue: currentPreset) ?? .drumsBitBrush)
                    
                }) {
                    Image(systemName: "arrowtriangle.forward.fill").foregroundColor(.blue)
                }
            }
            HStack {
                ForEach(conductor.distortion.parameters) {
                    ParameterRow(param: $0)
                }
                CookbookKnob(text: "Pre-Gain", parameter: $conductor.preGain, range: -20...20)
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.distortion,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Apple Distortion")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
