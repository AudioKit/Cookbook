import AudioKit
import AudioKitUI
import SporthAudioKit
import SwiftUI

class DroneOperationConductor: ObservableObject {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator {

        func drone(frequency: Double, rate: Double) -> OperationParameter {
            let metro = Operation.metronome(frequency: rate)
            let tone = Operation.sineWave(frequency: frequency, amplitude: 0.2)
            return tone.triggeredWithEnvelope(trigger: metro, attack: 0.01, hold: 0.1, release: 0.1)
        }

        let drone1 = drone(frequency: 440, rate: 3)
        let drone2 = drone(frequency: 330, rate: 5)
        let drone3 = drone(frequency: 450, rate: 7)

        return (drone1 + drone2 + drone3) / 3
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

struct DroneOperationView: View {
    @StateObject var conductor = DroneOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("Encapsualating functionality of operations into functions")
            Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
                conductor.isRunning.toggle()
            }
        }
        .padding()
        .cookbookNavBarTitle("Drone Operation")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
