import AudioKit
import SwiftUI

class ShakerConductor: ObservableObject {

    let engine = AudioEngine()
    let shaker = Shaker()
    let playRate = 4.0
    var loop: CallbackLoop!

    @Published var isRunning = false {
        didSet {
            isRunning ? loop.start() : loop.stop()
        }
    }

    init() {
        let delay = Delay(shaker)
        delay.time = AUValue(1.5 / playRate)
        delay.dryWetMix = 0.7
        delay.feedback = 0.2
        let reverb = Reverb(delay)
        engine.output = reverb
    }

    func start() {
        do {
            try engine.start()
            loop = CallbackLoop(frequency: playRate) {
                let type = ShakerType(rawValue: MIDIByte(AUValue.random(in: 0...22))) ?? .cabasa
                self.shaker.trigger(type: type, amplitude: Double(AUValue.random(in: 0.7...1.0)))
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

struct ShakerView: View {
    @ObservedObject var conductor = ShakerConductor()

    var body: some View {
        Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
            conductor.isRunning.toggle()
        }
        .padding()
        .navigationBarTitle(Text("Shaker"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
