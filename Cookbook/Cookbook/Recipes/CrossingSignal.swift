import AudioKit
import AudioKitUI
import SwiftUI

class CrossingSignalConductor: ObservableObject {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator {

        // Generate a sine wave at the right frequency
        let crossingSignalTone = Operation.sineWave(frequency: 2_500)

        // Periodically trigger an envelope around that signal
        let crossingSignalTrigger = Operation.periodicTrigger(period: 0.2)
        let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
            trigger: crossingSignalTrigger,
            attack: 0.01,
            hold: 0.1,
            release: 0.01)

        // scale the volume
        return crossingSignal * 0.2
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

struct CrossingSignalView: View {
    @StateObject var conductor = CrossingSignalConductor()

    var body: some View {
        VStack {
            Text("A British crossing signal implemented with AudioKit, an example from Andy Farnell's excellent book \"Designing Sound\"")
            Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
                conductor.isRunning.toggle()
            }
        }
        .padding()
        .navigationBarTitle(Text("Crossing Signal"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
