import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

struct MorphingOscillatorData {
    var isPlaying: Bool = false
    var index: AUValue = 0.0
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class MorphingOscillatorConductor: ObservableObject {
    let engine = AudioEngine()

    func noteOn(pitch: Pitch) {
        data.isPlaying = true
        data.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }

    func noteOff(pitch _: Pitch) {
        data.isPlaying = false
    }

    @Published var data = MorphingOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$index.ramp(to: data.index, duration: data.rampDuration)
                osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = MorphingOscillator()

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

struct MorphingOscillatorView: View {
    @StateObject var conductor = MorphingOscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Index",
                            parameter: self.$conductor.data.index,
                            range: 0 ... 3).padding(5)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220 ... 880).padding(5)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 4).padding(5)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0 ... 10).padding(5)

            NodeOutputView(conductor.osc)
            Keyboard(pitchRange: Pitch(48) ... Pitch(64),
                     noteOn: conductor.noteOn,
                     noteOff: conductor.noteOff)
        }
        .padding()
        .cookbookNavBarTitle("Morphing Oscillator")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct MorphingOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        MorphingOscillatorView()
    }
}
