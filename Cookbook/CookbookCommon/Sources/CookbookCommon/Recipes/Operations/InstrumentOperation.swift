import AudioKit
import AudioKitEX
import AudioKitUI
import SporthAudioKit
import SwiftUI

class InstrumentOperationConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator {
        func instrument(noteNumber: MIDINoteNumber, rate: Double, amplitude: Double) -> OperationParameter {
            let metro = Operation.metronome(frequency: 82.0 / (60.0 * rate))
            let frequency = Double(noteNumber.midiNoteToFrequency())
            let fm = Operation.fmOscillator(baseFrequency: frequency, amplitude: amplitude)

            return fm.triggeredWithEnvelope(trigger: metro, attack: 0.5, hold: 1, release: 1)
        }

        let instrument1 = instrument(noteNumber: 60, rate: 4, amplitude: 0.5)
        let instrument2 = instrument(noteNumber: 62, rate: 5, amplitude: 0.4)
        let instrument3 = instrument(noteNumber: 65, rate: 7, amplitude: 1.3 / 4.0)
        let instrument4 = instrument(noteNumber: 67, rate: 7, amplitude: 0.125)

        let instruments = (instrument1 + instrument2 + instrument3 + instrument4) * 0.13

        let reverb = instruments.reverberateWithCostello(feedback: 0.9, cutoffFrequency: 10000).toMono()

        return mixer(instruments, reverb, balance: 0.4)
    }

    init() {
        engine.output = generator
    }
}

struct InstrumentOperationView: View {
    @StateObject var conductor = InstrumentOperationConductor()

    var body: some View {
        VStack(spacing: 50) {
            Text("Encapsualating functionality of operations into functions")
            Text(conductor.isRunning ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isRunning.toggle()
            }
            NodeOutputView(conductor.generator)
        }
        .padding()
        .cookbookNavBarTitle("Instrument Operation")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
