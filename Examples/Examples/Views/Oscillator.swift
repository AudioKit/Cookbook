import AudioKit
import SwiftUI
import AudioToolbox

struct OscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class OscillatorConductor: Conductor, ObservableObject, AKKeyboardDelegate {

    let engine = AKEngine()

    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    @Published var data = OscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.frequency = data.frequency
                osc.amplitude = data.amplitude
                osc.rampDuration = data.rampDuration
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = AKOscillator()

    lazy var plot = AKNodeOutputPlot(osc)

    func start() {
        osc.amplitude = 0.2
        engine.output = osc
        do {
            try engine.start()
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

struct OscillatorView: View {
    @ObservedObject var conductor  = OscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220...880).padding()

            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 1).padding()
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10).padding()
            PlotView(view: conductor.plot)
            KeyboardView(delegate: conductor)

        }.navigationBarTitle(Text("Oscillator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView()
    }
}

