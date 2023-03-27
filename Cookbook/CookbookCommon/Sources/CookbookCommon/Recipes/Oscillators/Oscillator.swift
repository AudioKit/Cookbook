import AudioKit
import AudioKitEX
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterRow(param: $0)
                }
            }
            NodeOutputView(conductor.osc)
            CookbookKeyboard(noteOn: conductor.noteOn,
                             noteOff: conductor.noteOff)

        }.cookbookNavBarTitle("Oscillator")
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
