import AudioKit
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
            ParameterSlider(text: "Brownian", parameter: self.$conductor.data.brownianAmplitude, range: 0 ... 1).padding()
            ParameterSlider(text: "Pink", parameter: self.$conductor.data.pinkAmplitude, range: 0 ... 1).padding()
            ParameterSlider(text: "White", parameter: self.$conductor.data.whiteAmplitude, range: 0 ... 1).padding()
            NodeOutputView(conductor.mixer)
        }.navigationBarTitle(Text("Noise Generators"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct NoiseGeneratorsView_Previews: PreviewProvider {
    static var previews: some View {
        NoiseGeneratorsView()
    }
}
