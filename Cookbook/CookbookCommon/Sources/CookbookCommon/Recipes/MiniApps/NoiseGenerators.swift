import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Controls
import SoundpipeAudioKit
import SwiftUI

struct NoiseData {
    var brownianAmplitude: AUValue = 0.0
    var pinkAmplitude: AUValue = 0.0
    var whiteAmplitude: AUValue = 0.0
}

class NoiseGeneratorsConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var brown = BrownianNoise()
    var pink = PinkNoise()
    var white = WhiteNoise()
    var mixer = Mixer()

    @Published var data = NoiseData() {
        didSet {
            brown.amplitude = data.brownianAmplitude
            pink.amplitude = data.pinkAmplitude
            white.amplitude = data.whiteAmplitude
        }
    }

    init() {
        mixer.addInput(brown)
        mixer.addInput(pink)
        mixer.addInput(white)

        brown.amplitude = data.brownianAmplitude
        pink.amplitude = data.pinkAmplitude
        white.amplitude = data.whiteAmplitude
        brown.start()
        pink.start()
        white.start()

        engine.output = mixer
    }
}

struct NoiseGeneratorsView: View {
    @StateObject var conductor = NoiseGeneratorsConductor()

    var body: some View {
        VStack {
            HStack {
                CookbookKnob(text: "Brownian", parameter: self.$conductor.data.brownianAmplitude, range: 0...1)
                CookbookKnob(text: "Pink", parameter: self.$conductor.data.pinkAmplitude, range: 0...1)
                CookbookKnob(text: "White", parameter: self.$conductor.data.whiteAmplitude, range: 0...1)
            }.padding(5)
            NodeOutputView(conductor.mixer)
        }.cookbookNavBarTitle("Noise Generators")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
