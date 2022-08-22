import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class OscillatorConductor: ObservableObject, HasAudioEngine {
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

    var osc = Oscillator()

    init() {
        osc.amplitude = 0.2
        engine.output = osc
    }
}

struct OscillatorView: View {
    @StateObject var conductor = OscillatorConductor()

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

        }.cookbookNavBarTitle("Oscillator")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
