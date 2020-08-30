import AudioKit
import SwiftUI
import AudioToolbox

class NoiseGeneratorsConductor: Conductor, ObservableObject {
    @Published var refresh = true

    @Published var brown = AKBrownianNoise()
    @Published var pink = AKPinkNoise()
    @Published var white = AKWhiteNoise()

    override func setup() {
        AKManager.output = AKMixer(brown, pink, white)
    }
}

struct NoiseGeneratorsView: View {
    @ObservedObject var conductor = NoiseGeneratorsConductor()
//    var plotView = PlotView()

    var body: some View {
        VStack {
            ParameterSlider(text: "Brownian", parameter: self.$conductor.brown.amplitude, range: 0 ... 1)
            ParameterSlider(text: "Pink", parameter: self.$conductor.pink.amplitude, range: 0 ... 1)
            ParameterSlider(text: "White", parameter: self.$conductor.white.amplitude, range: 0 ... 1)
//            plotView
        }.navigationBarTitle(Text("Noise Generators"))
        .onAppear {
            self.conductor.start()
            self.conductor.brown.amplitude = 0.0
            self.conductor.pink.amplitude = 0.0
            self.conductor.white.amplitude = 0.0
            self.conductor.brown.start()
            self.conductor.pink.start()
            self.conductor.white.start()
            self.conductor.refresh.toggle()
//            self.plotView.attach()
        }
    }
}

struct NoiseGeneratorsView_Previews: PreviewProvider {
    static var previews: some View {
        NoiseGeneratorsView()
    }
}
