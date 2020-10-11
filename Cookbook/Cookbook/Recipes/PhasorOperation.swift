import AudioKit
import SwiftUI

class PhasorOperationConductor: ObservableObject {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator {
        let interval: Double = 2
        let noteCount: Double = 24
        let startingNote: Double = 48 // C

        let phasing = Operation.phasor(frequency: 0.5) * Operation.randomNumberPulse(minimum: 0.9, maximum: 2, updateFrequency: 0.5)
        let frequency = (floor(phasing * noteCount) * interval + startingNote)
            .midiNoteToFrequency()

        var amplitude = (phasing - 1).portamento() // prevents the click sound

        var oscillator = Operation.sineWave(frequency: frequency, amplitude: amplitude)
        let reverb = oscillator.reverberateWithChowning()
        return mixer(oscillator, reverb, balance: 0.6)
    }
    init() {
        engine.output = generator
    }

    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }
    func stop() {
        engine.stop()
    }
}

struct PhasorOperationView: View {
    @ObservedObject var conductor = PhasorOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("Using the phasor to sweep amplitude and frequencies")
            Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
                conductor.isRunning.toggle()
            }
        }
        .padding()
        .navigationBarTitle(Text("Phasor Operation"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
