import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

struct OscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class OscillatorConductor: ObservableObject {
    let engine = AudioEngine()

    func noteOn(pitch: Pitch, point _: CGPoint) {
        data.isPlaying = true
        data.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }

    func noteOff(pitch _: Pitch) {
        data.isPlaying = false
    }

    @Published var data = OscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = Oscillator()

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

struct OscillatorView: View {
    @StateObject var conductor = OscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220 ... 880).padding()
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 1).padding()
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0 ... 10).padding()
            NodeOutputView(conductor.osc)
            Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                     noteOn: conductor.noteOn,
                     noteOff: conductor.noteOff)

        }.cookbookNavBarTitle("Oscillator")
            .onAppear {
                self.conductor.start()
            }
            .onDisappear {
                self.conductor.stop()
            }
    }
}
