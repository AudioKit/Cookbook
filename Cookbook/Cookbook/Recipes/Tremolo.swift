import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct TremoloData {
    var frequency: AUValue = 10.0
    var depth: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class TremoloConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let tremolo: Tremolo
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        tremolo = Tremolo(player)
        dryWetMixer = DryWetMixer(player, tremolo)
        engine.output = dryWetMixer
    }

    @Published var data = TremoloData() {
        didSet {
            tremolo.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            tremolo.$depth.ramp(to: data.depth, duration: data.rampDuration)
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

struct TremoloView: View {
    @ObservedObject var conductor = TremoloConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0.0...200.0,
                            units: "Hertz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.tremolo, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Tremolo"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Tremolo_Previews: PreviewProvider {
    static var previews: some View {
        TremoloView()
    }
}
