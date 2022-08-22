import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class DynamicOscillatorConductor: ObservableObject {
    let engine = AudioEngine()

    func noteOn(pitch: Pitch, point _: CGPoint) {
        isPlaying = true
        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }

    func noteOff(pitch _: Pitch) {
        isPlaying = false
    }

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? osc.start() : osc.stop() }
    }

    var osc = DynamicOscillator()

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
        isPlaying = false
        osc.stop()
        engine.stop()
    }
}

struct DynamicOscillatorView: View {
    @StateObject var conductor = DynamicOscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.isPlaying.toggle()
            }
            Spacer()
            HStack {
                Spacer()
                Text("Sine").onTapGesture {
                    self.conductor.osc.setWaveform(Table(.sine))
                }
                Spacer()
                Text("Square").onTapGesture {
                    self.conductor.osc.setWaveform(Table(.square))
                }
                Spacer()
                Text("Triangle").onTapGesture {
                    self.conductor.osc.setWaveform(Table(.triangle))
                }
                Spacer()
                Text("Sawtooth").onTapGesture {
                    self.conductor.osc.setWaveform(Table(.sawtooth))
                }
                Spacer()
            }
            Spacer()
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterEditor2(param: $0)
                }
            }
            NodeOutputView(conductor.osc)
            Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                     noteOn: conductor.noteOn,
                     noteOff: conductor.noteOff)

        }.cookbookNavBarTitle("Dynamic Oscillator")
            .onAppear {
                self.conductor.start()
            }
            .onDisappear {
                self.conductor.stop()
            }
    }
}
