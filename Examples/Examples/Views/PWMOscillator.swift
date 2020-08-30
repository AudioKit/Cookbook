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

    let engine = AKEngine()

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

    lazy var plot = AKNodeOutputPlot2(nil)

    override func start() {
        osc.amplitude = 0.2
        engine.output = osc
        do {
            try engine.start()
            plot.node = osc
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
}

struct PWMOscillatorView: View {
    @ObservedObject var conductor  = PWMOscillatorConductor()
//    var plotView = PlotView()

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

            PlotView(view: conductor.plot)
            KeyboardView(delegate: conductor)

        }.navigationBarTitle(Text("PWM Oscillator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PWMOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        PWMOscillatorView()
    }
}
