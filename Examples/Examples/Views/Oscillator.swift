import AudioKit
import SwiftUI
import AudioToolbox

class OscillatorConductor: Conductor, ObservableObject {
    @Published var refresh = true

    @Published var osc = AKOscillator()

    @Published var rampDuration: AUValue = 0.002 {
        didSet { osc.rampDuration = Double(rampDuration) }
    }
    
    override func setup() {
        osc.amplitude = 0.2
        AKManager.output = osc
    }
}

struct OscillatorView: View {
    @ObservedObject var conductor  = OscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.osc.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.osc.isPlaying ? self.conductor.osc.stop() : self.conductor.osc.start()
                self.conductor.refresh.toggle()
            }
            ParameterSlider(text: "Frequency", parameter: self.$conductor.osc.frequency, range: 220...880)
            ParameterSlider(text: "Amplitude", parameter: self.$conductor.osc.amplitude, range: 0 ... 1)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.rampDuration,
                            range: 0...10)

        }.navigationBarTitle(Text("Oscillator"))
        .onAppear {
            self.conductor.start()
        }
    }
}

struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView()
    }
}
