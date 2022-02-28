import AudioKit
import AudioKitUI
import SporthAudioKit
import SwiftUI

class StereoOperationConductor: ObservableObject {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator(channelCount: 2) { _ in

        let slowSine = round(Operation.sineWave(frequency: 1) * 12) / 12
        let vibrato = slowSine.scale(minimum: -1_200, maximum: 1_200)

        let fastSine = Operation.sineWave(frequency: 10)
        let volume = fastSine.scale(minimum: 0, maximum: 0.5)

        let leftOutput = Operation.sineWave(frequency: 440 + vibrato, amplitude: volume)
        let rightOutput = Operation.sineWave(frequency: 220 + vibrato, amplitude: volume)

        return [leftOutput, rightOutput]
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

struct StereoOperationView: View {
    @StateObject var conductor = StereoOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("This is an example of building a stereo sound generator.")
            Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
                conductor.isRunning.toggle()
            }
        }
        .padding()
        .cookbookNavBarTitle("Stereo Operation")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
