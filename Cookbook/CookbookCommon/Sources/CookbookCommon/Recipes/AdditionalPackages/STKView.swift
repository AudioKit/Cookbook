import AudioKit
import AudioKitEX
import AudioKitUI
import STKAudioKit
import SwiftUI

struct ShakerMetronomeData {
    var isPlaying = false
    var tempo: BPM = 120
    var timeSignatureTop: Int = 4
    var downbeatNoteNumber = MIDINoteNumber(6)
    var beatNoteNumber = MIDINoteNumber(10)
    var beatNoteVelocity = 100.0
    var currentBeat = 0
}

class ShakerConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let shaker = Shaker()
    var callbackInst = CallbackInstrument()
    let reverb: Reverb
    let mixer = Mixer()
    var sequencer = Sequencer()

    @Published var data = ShakerMetronomeData() {
        didSet {
            data.isPlaying ? sequencer.play() : sequencer.stop()
            sequencer.tempo = data.tempo
            updateSequences()
        }
    }

    func updateSequences() {
        var track = sequencer.tracks.first!

        track.length = Double(data.timeSignatureTop)

        track.clear()
        track.sequence.add(noteNumber: data.downbeatNoteNumber, position: 0.0, duration: 0.4)
        let vel = MIDIVelocity(Int(data.beatNoteVelocity))
        for beat in 1 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: data.beatNoteNumber, velocity: vel, position: Double(beat), duration: 0.1)
        }

        track = sequencer.tracks[1]
        track.length = Double(data.timeSignatureTop)
        track.clear()
        for beat in 0 ..< data.timeSignatureTop {
            track.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
        }
    }

    init() {
        let fader = Fader(shaker)
        fader.gain = 20.0

        //        let delay = Delay(fader)
        //        delay.time = AUValue(1.5 / playRate)
        //        delay.dryWetMix = 0.7
        //        delay.feedback = 0.2
        reverb = Reverb(fader)

        _ = sequencer.addTrack(for: shaker)

        callbackInst = CallbackInstrument(midiCallback: { _, beat, _ in
            DispatchQueue.main.async { [unowned self] in
                self.data.currentBeat = Int(beat)
                print(beat)
            }
        })

        _ = sequencer.addTrack(for: callbackInst)
        updateSequences()

        mixer.addInput(reverb)
        mixer.addInput(callbackInst)

        engine.output = mixer
    }
}

struct STKView: View {
    @StateObject var conductor = ShakerConductor()

    func name(noteNumber: MIDINoteNumber) -> String {
        let str = "\(ShakerType(rawValue: noteNumber)!)"
        return str.titleCase()
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(conductor.data.isPlaying ? "Stop" : "Start").onTapGesture {
                    conductor.data.isPlaying.toggle()
                }
                VStack {
                    Text("Tempo: \(Int(conductor.data.tempo))")
                    Slider(value: $conductor.data.tempo, in: 60.0 ... 240.0, label: {
                        Text("Tempo")
                    })
                }

                VStack {
                    Stepper("Downbeat: \(name(noteNumber: conductor.data.downbeatNoteNumber))", onIncrement: {
                        if conductor.data.downbeatNoteNumber <= 21 {
                            conductor.data.downbeatNoteNumber += 1
                        }
                    }, onDecrement: {
                        if conductor.data.downbeatNoteNumber >= 1 {
                            conductor.data.downbeatNoteNumber -= 1
                        }
                    })
                    Stepper("Other beats: \(name(noteNumber: conductor.data.beatNoteNumber))", onIncrement: {
                        if conductor.data.beatNoteNumber <= 21 {
                            conductor.data.beatNoteNumber += 1
                        }
                    }, onDecrement: {
                        if conductor.data.beatNoteNumber >= 1 {
                            conductor.data.beatNoteNumber -= 1
                        }
                    })
                }

                VStack {
                    Text("Velocity")
                    Slider(value: $conductor.data.beatNoteVelocity, in: 0.0 ... 127.0, label: {
                        Text("Velocity")
                    })
                }
            }
            Spacer()

            HStack(spacing: 10) {
                ForEach(0 ..< conductor.data.timeSignatureTop, id: \.self) { index in
                    ZStack {
                        Circle().foregroundColor(conductor.data.currentBeat == index ? .red : .white)
                        Text("\(index + 1)").foregroundColor(.black)
                    }.onTapGesture {
                        conductor.data.timeSignatureTop = index + 1
                    }
                }
                ZStack {
                    Circle().foregroundColor(.white)
                    Text("+").foregroundColor(.black)
                }
                .onTapGesture {
                    conductor.data.timeSignatureTop += 1
            }
            }.padding()

        FFTView(conductor.reverb)
        }
        .navigationTitle("STK Demo")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
