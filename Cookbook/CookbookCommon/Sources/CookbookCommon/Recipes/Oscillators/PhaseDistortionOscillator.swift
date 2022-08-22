import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

struct PhaseDistortionOscillatorData {
    var isPlaying: Bool = false
    var phaseDistortion: AUValue = 1.0
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class PhaseDistortionOscillatorConductor: ObservableObject {
    let engine = AudioEngine()

    func noteOn(pitch: Pitch, point _: CGPoint) {
        data.isPlaying = true
        data.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }

    func noteOff(pitch _: Pitch) {
        data.isPlaying = false
    }

    @Published var data = PhaseDistortionOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$phaseDistortion.ramp(to: data.phaseDistortion, duration: data.rampDuration)
                osc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)

            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = PhaseDistortionOscillator()

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

struct PhaseDistortionOscillatorView: View {
    @StateObject var conductor = PhaseDistortionOscillatorConductor()

    var body: some View {
        VStack {
            Text(conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Phase Distortion",
                            parameter: self.$conductor.data.phaseDistortion,
                            range: -1 ... 1,
                            format: "%0.2f").padding(5)
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220 ... 880,
                            format: "%0.2f").padding(5)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 1,
                            format: "%0.2f").padding(5)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0 ... 10,
                            format: "%0.2f").padding(5)

            NodeOutputView(conductor.osc)
            Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                     noteOn: conductor.noteOn,
                     noteOff: conductor.noteOff)

        }.cookbookNavBarTitle("Phase Distortion Oscillator")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
