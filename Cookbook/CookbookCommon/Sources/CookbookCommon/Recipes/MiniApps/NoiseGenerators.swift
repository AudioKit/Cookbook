import AudioKit
import Controls
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

struct NoiseData {
    var brownianAmplitude: AUValue = 0.0
    var pinkAmplitude: AUValue = 0.0
    var whiteAmplitude: AUValue = 0.0
}

class NoiseGeneratorsConductor: ObservableObject {
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

    let engine = AudioEngine()

    init() {
        mixer.addInput(brown)
        mixer.addInput(pink)
        mixer.addInput(white)
        engine.output = mixer
    }

    func start() {
        brown.amplitude = data.brownianAmplitude
        pink.amplitude = data.pinkAmplitude
        white.amplitude = data.whiteAmplitude
        brown.start()
        pink.start()
        white.start()
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct NoiseGeneratorsView: View {
    @StateObject var conductor = NoiseGeneratorsConductor()

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .center) {
                    Text("Brownian").font(.title2)
                    SimpleKnob(value: self.$conductor.data.brownianAmplitude)
                }
                VStack(alignment: .center) {
                    Text("Pink").font(.title2)
                    SimpleKnob(value: self.$conductor.data.pinkAmplitude)
                }
                VStack(alignment: .center) {
                    Text("White").font(.title2)
                    SimpleKnob(value: self.$conductor.data.whiteAmplitude)
                }
            }
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
