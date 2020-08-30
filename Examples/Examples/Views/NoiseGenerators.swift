import AudioKit
import SwiftUI
import AudioToolbox

struct NoiseData {
    var brownianAmplitude: AUValue = 0.0
    var pinkAmplitude: AUValue = 0.0
    var whiteAmplitude: AUValue = 0.0
}

class NoiseGeneratorsConductor: Conductor, ObservableObject {
    var brown = AKBrownianNoise()
    var pink = AKPinkNoise()
    var white = AKWhiteNoise()

    @Published var data = NoiseData() {
        didSet {
            brown.amplitude = data.brownianAmplitude
            pink.amplitude = data.pinkAmplitude
            white.amplitude = data.whiteAmplitude
        }
    }
    let engine = AKEngine()
    lazy var plot = AKNodeOutputPlot2(nil)

    override func start() {
        engine.output = AKMixer2(brown, pink, white)
        brown.amplitude = data.brownianAmplitude
        pink.amplitude = data.pinkAmplitude
        white.amplitude = data.whiteAmplitude
        brown.start()
        pink.start()
        white.start()
        do {
            try engine.start()
            plot.node = engine.output
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct NoiseGeneratorsView: View {
    @ObservedObject var conductor = NoiseGeneratorsConductor()

    var body: some View {
        VStack {
            ParameterSlider(text: "Brownian", parameter: self.$conductor.data.brownianAmplitude, range: 0 ... 1)
            ParameterSlider(text: "Pink", parameter: self.$conductor.data.pinkAmplitude, range: 0 ... 1)
            ParameterSlider(text: "White", parameter: self.$conductor.data.whiteAmplitude, range: 0 ... 1)
            PlotView(view: conductor.plot)
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
