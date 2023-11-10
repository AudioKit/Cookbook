import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic

class DynamicOscillatorConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var osc = DynamicOscillator()

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

    init() {
        osc.amplitude = 0.2
        engine.output = osc
    }
}

struct DynamicOscillatorView: View {
    @StateObject var conductor = DynamicOscillatorConductor()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }
            Spacer()
            HStack {
                Spacer()
                Text("Sine").onTapGesture {
                    conductor.osc.setWaveform(Table(.sine))
                }
                Spacer()
                Text("Square").onTapGesture {
                    conductor.osc.setWaveform(Table(.square))
                }
                Spacer()
                Text("Triangle").onTapGesture {
                    conductor.osc.setWaveform(Table(.triangle))
                }
                Spacer()
                Text("Sawtooth").onTapGesture {
                    conductor.osc.setWaveform(Table(.sawtooth))
                }
                Spacer()
            }
            Spacer()
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterRow(param: $0)
                }
            }
            NodeOutputView(conductor.osc)
            CookbookKeyboard(noteOn: conductor.noteOn,
                             noteOff: conductor.noteOff)

        }.cookbookNavBarTitle("Dynamic Oscillator")
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
