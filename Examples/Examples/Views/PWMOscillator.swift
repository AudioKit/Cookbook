import AudioKit
import SwiftUI
import AudioToolbox

struct PWMOscillatorData {
    var isPlaying: Bool = false
    var pulseWidth: AUValue = 0.5
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class PWMOscillatorConductor: Conductor, ObservableObject, AKKeyboardDelegate {
    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    @Published var data = PWMOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.pulseWidth = data.pulseWidth
                osc.frequency = data.frequency
                osc.amplitude = data.amplitude
                osc.rampDuration = data.rampDuration
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = AKPWMOscillator()

    override func setup() {
        osc.amplitude = 0.2
        AKManager.output = osc
    }
}

struct PWMOscillatorView: View {
    @ObservedObject var conductor  = PWMOscillatorConductor()
    var plotView = PlotView()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Pulse Width",
                            parameter: self.$conductor.data.pulseWidth,
                            range: 0 ... 1)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220...880)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 1)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10)

            plotView

            KeyboardView(delegate: conductor)

        }.navigationBarTitle(Text("PWM Oscillator"))
        .onAppear {
            self.conductor.start()
            self.plotView.attach()
        }
    }
}

struct PWMOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        PWMOscillatorView()
    }
}
