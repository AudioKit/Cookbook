import AudioKit
import AudioKitUI
import SoundpipeAudioKit
import SwiftUI
import AudioToolbox

struct DynamicOscillatorData {
    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class DynamicOscillatorConductor: ObservableObject, KeyboardDelegate {

    let engine = AudioEngine()

    func noteOn(note: MIDINoteNumber) {
        data.isPlaying = true
        data.frequency = note.midiNoteToFrequency()
    }

    func noteOff(note: MIDINoteNumber) {
        data.isPlaying = false
    }

    @Published var data = DynamicOscillatorData() {
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
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
}

struct DynamicOscillatorView: View {
    @StateObject var conductor = DynamicOscillatorConductor()
    @State var firstOctave = 0
    @State var octaveCount = 2
    @State var polyphonicMode = false

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
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
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 220...880).padding()
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 1).padding()
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10).padding()
            NodeOutputView(conductor.osc)
            HStack {
                VStack {
                    Text("First Octave")
                        .fontWeight(.bold)
                    HStack {
                        Button(
                        action: {
                            firstOctave -= 1
                        },
                        label: {
                            Text("-")
                        })
                        Text("\(firstOctave)")
                        Button(
                        action: {
                            firstOctave += 1
                        },
                        label: {
                            Text("+")
                        })
                    }
                }
                .padding()
                VStack {
                    Text("Octave Count")
                        .fontWeight(.bold)
                    HStack {
                        Button(
                        action: {
                            octaveCount -= 1
                        },
                        label: {
                            Text("-")
                        })
                        Text("\(octaveCount)")
                        Button(
                        action: {
                            octaveCount += 1
                        },
                        label: {
                            Text("+")
                        })
                    }
                }
                .padding()
                VStack {
                    Text("Polyphonic Mode")
                        .fontWeight(.bold)
                    HStack {
                        Button(
                        action: {
                            polyphonicMode.toggle()
                        },
                        label: {
                            Text("Toggle:")
                        })
                        if polyphonicMode {
                            Text("ON")
                        } else {
                            Text("OFF")
                        }
                    }
                }
            }
            KeyboardWidget(delegate: conductor,
                           firstOctave: firstOctave,
                           octaveCount: octaveCount,
                           polyphonicMode: polyphonicMode)

        }.navigationBarTitle(Text("Dynamic Oscillator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct DynamicOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicOscillatorView()
    }
}
