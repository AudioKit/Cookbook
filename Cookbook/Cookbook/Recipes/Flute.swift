import AudioKit
import AudioKitUI
import SwiftUI

class FluteConductor: ObservableObject {

    let engine = AudioEngine()
    let flute = Flute()

    var loop: CallbackLoop!

    @Published var isRunning = false {
        didSet {
            isRunning ? loop.start() : loop.stop()
        }
    }

    init() {
        let reverb = Reverb(flute)
        engine.output = reverb
    }

    func start() {
        do {
            try engine.start()
            loop = CallbackLoop(frequency: 2) {
                let scale = [0, 2, 4, 5, 7, 9, 11, 12]
                var note = scale.randomElement()!
                let octave = (2..<6).randomElement()! * 12
                if AUValue.random(in: 0...10) < 1.0 { note += 1 }

                self.flute.stop()
                if AUValue.random(in: 0...6) > 1.0 {
                    self.flute.trigger(note: MIDINoteNumber(note + octave), velocity: 40)
                }
            }
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
        loop.stop()
    }
}

struct FluteView: View {
    @ObservedObject var conductor = FluteConductor()

    var body: some View {
        Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
            conductor.isRunning.toggle()
        }
        .padding()
        .navigationBarTitle(Text("Flute"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
