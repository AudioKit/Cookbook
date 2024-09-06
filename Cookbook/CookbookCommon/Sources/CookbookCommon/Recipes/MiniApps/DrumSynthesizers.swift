import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class DrumSynthesizersConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let kick = SynthKick()
    let snare = SynthSnare(duration: 0.07)
    var reverb: Reverb
    var loop: CallbackLoop!
    var counter = 0

    @Published var isRunning = false {
        didSet {
            isRunning ? loop.start() : loop.stop()
        }
    }

    init() {
        let mix = Mixer(kick, snare)
        reverb = Reverb(mix)
        engine.output = reverb

        loop = CallbackLoop(frequency: 5) {
            let randomVelocity = MIDIVelocity(AUValue.random(in: 0 ... 127))
            let onFirstBeat = self.counter % 4 == 0
            let everyOtherBeat = self.counter % 4 == 2
            let randomHit = Array(0 ... 3).randomElement() == 0

            if onFirstBeat || randomHit {
                print("play kick")
                self.kick.play(noteNumber: 60, velocity: randomVelocity)
                self.kick.stop(noteNumber: 60)
            }

            if everyOtherBeat {
                print("play snare")
                let velocity = MIDIVelocity(Array(0 ... 100).randomElement()!)
                self.snare.play(noteNumber: 60, velocity: velocity, channel: 0)
                self.snare.stop(noteNumber: 60)
            }
            self.counter += 1
        }
    }
}

struct DrumSynthesizersView: View {
    @StateObject var conductor = DrumSynthesizersConductor()

    var body: some View {
        VStack {
            Text(conductor.isRunning ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isRunning.toggle()
            }
            NodeOutputView(conductor.reverb)
        }
        .padding()
        .cookbookNavBarTitle("Drum Synthesizers")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.isRunning = false
            conductor.stop()
        }
    }
}
