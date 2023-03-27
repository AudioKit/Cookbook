import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class LFOOperationConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator {
        let frequencyLFO = Operation.square(frequency: 1)
            .scale(minimum: 440, maximum: 880)
        let carrierLFO = Operation.triangle(frequency: 1)
            .scale(minimum: 1, maximum: 2)
        let modulatingMultiplierLFO = Operation.sawtooth(frequency: 1)
            .scale(minimum: 0.1, maximum: 2)
        let modulatingIndexLFO = Operation.reverseSawtooth(frequency: 1)
            .scale(minimum: 0.1, maximum: 20)

        return Operation.fmOscillator(
            baseFrequency: frequencyLFO,
            carrierMultiplier: carrierLFO,
            modulatingMultiplier: modulatingMultiplierLFO,
            modulationIndex: modulatingIndexLFO,
            amplitude: 0.2
        )
    }

    init() {
        engine.output = generator
    }
}

struct LFOOperationView: View {
    @StateObject var conductor = LFOOperationConductor()

    var body: some View {
        VStack(spacing: 50) {
            Text("Often we want rhythmic changing of parameters that varying in a standard way. This is traditionally done with Low-Frequency Oscillators, LFOs.")
            Text(conductor.isRunning ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isRunning.toggle()
            }
            NodeOutputView(conductor.generator)
        }
        .padding()
        .cookbookNavBarTitle("LFO Operation")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
