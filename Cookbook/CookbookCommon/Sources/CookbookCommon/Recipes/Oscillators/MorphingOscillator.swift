import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class MorphingOscillatorConductor: ObservableObject, HasAudioEngine {

    var engine = AudioEngine()

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

    var osc = MorphingOscillator()

    init() {
        osc.amplitude = 0.2
        engine.output = osc
    }
}

struct MorphingOscillatorView: View {
    @StateObject var conductor = MorphingOscillatorConductor()

    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START").onTapGesture {
                conductor.isPlaying.toggle()
            }
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterEditor2(param: $0)
                }
            }

            NodeOutputView(conductor.osc)
            Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                     noteOn: conductor.noteOn,
                     noteOff: conductor.noteOff)
        }
        .padding()
        .cookbookNavBarTitle("Morphing Oscillator")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
