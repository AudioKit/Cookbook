import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class PolyphonicOscillatorConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var notes = Array(repeating: 0, count: 11)
    var osc = [Oscillator(), Oscillator(), Oscillator(), Oscillator(), Oscillator(),
               Oscillator(), Oscillator(), Oscillator(), Oscillator(), Oscillator(), Oscillator()]

    func noteOn(pitch: Pitch, point _: CGPoint) {
        for num in 0 ... 10 {
            if notes[num] == 0 {
                osc[num].frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
                osc[num].$amplitude.ramp(to: 0.2, duration: 0.005)
                notes[num] = pitch.intValue
                break
            }
        }
    }

    func noteOff(pitch: Pitch) {
        for num in 0 ... 10 {
            if notes[num] == pitch.intValue {
                osc[num].$amplitude.ramp(to: 0, duration: 0.005)
                notes[num] = 0
                break
            }
        }
    }

    init() {
        for num in 0 ... 10 {
            osc[num].amplitude = 0.0
            osc[num].start()
        }
        engine.output = Mixer(osc[0], osc[1], osc[2], osc[3], osc[4], osc[5],
                              osc[6], osc[7], osc[8], osc[9], osc[10])
    }
}

struct PolyphonicOscillatorView: View {
    @StateObject var conductor = PolyphonicOscillatorConductor()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if conductor.engine.output != nil {
            NodeOutputView(conductor.engine.output!)
        }
        CookbookKeyboard(noteOn: conductor.noteOn,
                         noteOff: conductor.noteOff)
        .cookbookNavBarTitle("Polyphonic Oscillator")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}
