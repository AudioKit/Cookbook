import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class PWMOscillatorConductor: ObservableObject {
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
        isPlaying = false
        osc.stop()
            engine.stop()
    }
}

struct PWMOscillatorView: View {
    @StateObject var conductor = PWMOscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.isPlaying.toggle()
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
