import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SwiftUI

class CallbackInstrumentConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var sequencer = AppleSequencer()

    var tempo = 120.0
    var division = 1

    @Published var text = ""

    init() {
        let callbacker = MIDICallbackInstrument { [self] status, note, _ in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            if midiStatus == .noteOn {
                DispatchQueue.main.async {
                    self.text = "Start Note \(note) at \(self.sequencer.currentPosition.seconds)"
                }
            }
        }

        let clickTrack = sequencer.newTrack()
        for i in 0 ..< division {
            clickTrack?.add(noteNumber: 80,
                            velocity: 100,
                            position: Duration(beats: Double(i) / Double(division)),
                            duration: Duration(beats: Double(0.1 / Double(division))))
            clickTrack?.add(noteNumber: 60,
                            velocity: 100,
                            position: Duration(beats: (Double(i) + 0.5) / Double(division)),
                            duration: Duration(beats: Double(0.1 / Double(division))))
        }

        clickTrack?.setMIDIOutput(callbacker.midiIn)
        clickTrack?.setLoopInfo(Duration(beats: 1.0), loopCount: 10)
        sequencer.setTempo(tempo)

        //: We must link the clock's output to AudioKit (even if we don't need the sound)
        engine.output = callbacker
    }
}

struct CallbackInstrumentView: View {
    @StateObject var conductor = CallbackInstrumentConductor()

    var body: some View {
        VStack(spacing: 30) {
            Text("Play")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.sequencer.play()
            }
            Text("Pause")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.sequencer.stop()
            }
            Text("Rewind")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.sequencer.rewind()
            }
            Text(conductor.text)
        }.cookbookNavBarTitle("Callback Instrument")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
