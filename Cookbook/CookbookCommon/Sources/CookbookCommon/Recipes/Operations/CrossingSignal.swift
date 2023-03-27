import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class CrossingSignalConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator {
        // Generate a sine wave at the right frequency
        let crossingSignalTone = Operation.sineWave(frequency: 2500)

        // Periodically trigger an envelope around that signal
        let crossingSignalTrigger = Operation.periodicTrigger(period: 0.2)
        let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
            trigger: crossingSignalTrigger,
            attack: 0.01,
            hold: 0.1,
            release: 0.01
        )

        // scale the volume
        return crossingSignal * 0.2
    }

    init() {
        engine.output = generator
    }
}

struct CrossingSignalView: View {
    @StateObject var conductor = CrossingSignalConductor()

    var body: some View {
        VStack(spacing: 50) {
            Text("A British crossing signal implemented with AudioKit, an example from Andy Farnell's excellent book \"Designing Sound\"")
            Text(conductor.isRunning ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isRunning.toggle()
            }
            NodeOutputView(conductor.generator)
        }
        .padding()
        .cookbookNavBarTitle("Crossing Signal")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
