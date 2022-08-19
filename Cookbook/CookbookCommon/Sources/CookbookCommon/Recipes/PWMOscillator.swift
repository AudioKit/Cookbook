import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

struct PWMOscillatorData {
    var isPlaying: Bool = false
    var pulseWidth: AUValue = 0.5
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class PWMOscillatorConductor: ObservableObject {
    let engine = AudioEngine()

    func noteOn(pitch: Pitch, point _: CGPoint) {
        data.isPlaying = true
        data.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }

    func noteOff(pitch _: Pitch) {
        data.isPlaying = false
    }

    @Published var data = PWMOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$pulseWidth.ramp(to: data.pulseWidth, duration: data.rampDuration)
                osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)

            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = PWMOscillator()

    init() {
        engine.output = osc
    }

    func start() {
        osc.amplitude = 0.2

        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
}

struct PWMOscillatorView: View {
    @StateObject var conductor = PWMOscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }

            ForEach(conductor.osc.parameters) {
                ParameterEditor(param: $0)
            }
            ParameterSlider(text: "Pulse Width",
                            parameter: self.$conductor.data.pulseWidth,
                            range: 0 ... 1).padding(5)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220 ... 880).padding(5)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 1).padding(5)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0 ... 10).padding(5)

            NodeOutputView(conductor.osc)
            Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                     noteOn: conductor.noteOn,
                     noteOff: conductor.noteOff)

        }.cookbookNavBarTitle("PWM Oscillator")
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
