import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct FlatFrequencyResponseReverbData {
    var reverbDuration: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class FlatFrequencyResponseReverbConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: FlatFrequencyResponseReverb
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        reverb = FlatFrequencyResponseReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        engine.output = dryWetMixer
    }

    @Published var data = FlatFrequencyResponseReverbData() {
        didSet {
            reverb.$reverbDuration.ramp(to: data.reverbDuration, duration: data.rampDuration)
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

struct FlatFrequencyResponseReverbView: View {
    @ObservedObject var conductor = FlatFrequencyResponseReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Reverb Duration",
                            parameter: self.$conductor.data.reverbDuration,
                            range: 0...10,
                            units: "Seconds")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.reverb, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Flat Frequency Response Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct FlatFrequencyResponseReverb_Previews: PreviewProvider {
    static var previews: some View {
        FlatFrequencyResponseReverbView()
    }
}
