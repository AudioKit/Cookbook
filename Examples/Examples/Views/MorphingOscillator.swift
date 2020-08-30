import AudioKit
import SwiftUI
import AudioToolbox

struct MorphingOscillatorData {
    var isPlaying: Bool = false
    var index: AUValue = 0.0
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class MorphingOscillatorConductor: Conductor, ObservableObject, AKKeyboardDelegate {
    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    @Published var data = MorphingOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.index = data.index
                osc.frequency = data.frequency
                osc.amplitude = data.amplitude
                osc.rampDuration = data.rampDuration
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = AKMorphingOscillator()

    override func setup() {
        osc.amplitude = 0.2
        AKManager.output = osc
    }
}

struct MorphingOscillatorView: View {
    @ObservedObject var conductor  = MorphingOscillatorConductor()
//    var plotView = PlotView()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Index",
                            parameter: self.$conductor.data.index,
                            range: 0 ... 3)
            Text("Index: Sine = 0, Triangle = 1, Sawtooth = 2, Square = 3")
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220...880)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 4)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10)

//            plotView
            KeyboardView(delegate: conductor)

        }.navigationBarTitle(Text("Morphing Oscillator"))
        .onAppear {
            self.conductor.start()
//            self.plotView.attach()
        }
    }
}

struct MorphingOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        MorphingOscillatorView()
    }
}
